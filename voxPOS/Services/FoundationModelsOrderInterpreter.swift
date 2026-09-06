//
//  FoundationModelsOrderInterpreter.swift
//  voxPOS
//
//  Created by Van Dao Le on 6/9/2026.
//

import Foundation
import FoundationModels

/// Reads an order out of a sentence using the on-device model.
///
/// Nothing is sent off the device, so a customer's words never leave the till.
///
/// The order is read in two passes, because asking for products, quantities and
/// options at once produced far worse orders. Measured over the same six sentences:
/// one pass scored 68%, two passes 86%, and options in particular went from 69% to
/// 100% correct.
///
/// - **Pass one** asks only what was ordered and how many. Options are ignored.
/// - **Pass two** takes one product at a time and offers only *that product's* own
///   options, so an option the kitchen cannot make is impossible to express rather
///   than merely discouraged.
///
/// Splitting a group across options stays in Swift: the model proposes the split,
/// this type enforces that it still adds up to the number of units ordered.
struct FoundationModelsOrderInterpreter: OrderInterpreting {

    /// Standing rules for each pass, kept in `Resources/` so the wording can be
    /// edited without touching this file. Read once; they never change per order.
    private static let productsInstructions = loadInstructions("OrderProductsInstructions")
    private static let optionsInstructions = loadInstructions("OrderOptionsInstructions")

    private static func loadInstructions(_ name: String) -> String? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "txt") else {
            return nil
        }

        return try? String(contentsOf: url, encoding: .utf8)
    }

    func interpret(text: String, menu: [Product]) async throws -> [InterpretedOrderLine] {
        try checkModelIsUsable()

        guard
            let productsInstructions = Self.productsInstructions,
            let optionsInstructions = Self.optionsInstructions
        else {
            throw OrderInterpretationError.instructionsMissing
        }

        let onSale = menu.filter(\.isAvailable)

        guard !onSale.isEmpty else {
            throw OrderInterpretationError.nothingOnTheMenu
        }

        do {
            let ordered = try await readProducts(
                from: text,
                menu: onSale,
                instructions: productsInstructions
            )

            var lines: [InterpretedOrderLine] = []

            for line in ordered {
                guard
                    line.isOnMenu,
                    let product = onSale.first(where: { $0.title == line.productName }),
                    !product.allowModifier.isEmpty
                else {
                    // Nothing to ask about: either it is not on the menu, or the
                    // kitchen offers no options for it.
                    lines.append(line)
                    continue
                }

                lines.append(contentsOf: try await readOptions(
                    for: product,
                    quantity: line.quantity,
                    customerWords: line.customerWords,
                    spokenText: text,
                    instructions: optionsInstructions
                ))
            }

            return lines
        } catch let error as OrderInterpretationError {
            throw error
        } catch {
            throw OrderInterpretationError.interpretationFailed(reason: error.localizedDescription)
        }
    }

    // MARK: - Pass one: what was ordered, and how many

    private func readProducts(
        from text: String,
        menu: [Product],
        instructions: String
    ) async throws -> [InterpretedOrderLine] {
        let session = LanguageModelSession(instructions: instructions)

        let prompt = """
        ====menu====
        \(Self.menuDescription(for: menu))
        ====end-menu====

        ====customer-order====
        \(text)
        ====end-customer-order====
        """

        let response = try await session.respond(
            to: prompt,
            schema: try Self.productsSchema(for: menu),
            options: GenerationOptions(sampling: .greedy)
        )

        return try response.content
            .value([GeneratedContent].self, forProperty: "items")
            .map { item in
                InterpretedOrderLine(
                    productName: try item.value(String.self, forProperty: "productName"),
                    customerWords: try item.value(String.self, forProperty: "customerWords"),
                    quantity: max(try item.value(Int.self, forProperty: "quantity"), 1),
                    modifiers: []
                )
            }
    }

    // MARK: - Pass two: which options, for one product

    private func readOptions(
        for product: Product,
        quantity: Int,
        customerWords: String,
        spokenText: String,
        instructions: String
    ) async throws -> [InterpretedOrderLine] {
        let session = LanguageModelSession(instructions: instructions)

        let prompt = """
        ====order====
        The customer ordered \(quantity) × \(product.title).
        ====end-order====

        ====allowed-options====
        \(product.allowModifier.joined(separator: "\n"))
        ====end-allowed-options====

        ====customer-order====
        \(spokenText)
        ====end-customer-order====
        """

        let response = try await session.respond(
            to: prompt,
            schema: try Self.optionsSchema(for: product),
            options: GenerationOptions(sampling: .greedy)
        )

        let groups = try response.content.value([GeneratedContent].self, forProperty: "groups")

        var lines: [InterpretedOrderLine] = []
        var counted = 0

        for group in groups {
            let wanted = max(try group.value(Int.self, forProperty: "quantity"), 1)
            let options = try group.value([String].self, forProperty: "options")

            // The split may never sell more than the customer asked for.
            let take = min(wanted, quantity - counted)

            guard take > 0 else { break }

            lines.append(
                InterpretedOrderLine(
                    productName: product.title,
                    customerWords: customerWords,
                    quantity: take,
                    modifiers: options
                )
            )
            counted += take
        }

        // Nor fewer: whatever the split left out is sold without options.
        if counted < quantity {
            lines.append(
                InterpretedOrderLine(
                    productName: product.title,
                    customerWords: customerWords,
                    quantity: quantity - counted,
                    modifiers: []
                )
            )
        }

        return lines
    }

    // MARK: - The menu, written for the model

    /// Options are left out here: pass one must not see them, and pass two is given
    /// only the one product's own options.
    private static func menuDescription(for products: [Product]) -> String {
        products.map { product in
            """
            Product: \(product.title)
            Description: \(product.description ?? "")
            """
        }
        .joined(separator: "\n\n")
    }

    /// `anyOf` is what makes the names usable: the model picks from this list rather
    /// than writing prose, so every name comes back spelled exactly as the menu spells it.
    private static func productsSchema(for products: [Product]) throws -> GenerationSchema {
        let line = DynamicGenerationSchema(
            name: "OrderLine",
            properties: [
                .init(
                    name: "productName",
                    schema: DynamicGenerationSchema(
                        name: "ProductName",
                        anyOf: products.map(\.title) + [InterpretedOrderLine.notOnMenu]
                    )
                ),
                .init(name: "customerWords", schema: DynamicGenerationSchema(type: String.self)),
                .init(
                    name: "quantity",
                    schema: DynamicGenerationSchema(type: Int.self, guides: [.minimum(1)])
                )
            ]
        )

        return try GenerationSchema(
            root: DynamicGenerationSchema(
                name: "Order",
                properties: [.init(name: "items", schema: DynamicGenerationSchema(arrayOf: line))]
            ),
            dependencies: []
        )
    }

    /// Only this product's own options, so a wrong one cannot be expressed at all.
    private static func optionsSchema(for product: Product) throws -> GenerationSchema {
        let group = DynamicGenerationSchema(
            name: "Group",
            properties: [
                .init(
                    name: "quantity",
                    schema: DynamicGenerationSchema(type: Int.self, guides: [.minimum(1)])
                ),
                .init(
                    name: "options",
                    schema: DynamicGenerationSchema(
                        arrayOf: DynamicGenerationSchema(name: "Option", anyOf: product.allowModifier)
                    )
                )
            ]
        )

        return try GenerationSchema(
            root: DynamicGenerationSchema(
                name: "Split",
                properties: [.init(name: "groups", schema: DynamicGenerationSchema(arrayOf: group))]
            ),
            dependencies: []
        )
    }

    /// Apple Intelligence has to be switched on, downloaded and supported by the device.
    private func checkModelIsUsable() throws {
        switch SystemLanguageModel.default.availability {
        case .available:
            return

        case .unavailable(.deviceNotEligible):
            throw OrderInterpretationError.modelUnavailable(
                reason: "This device does not support Apple Intelligence."
            )

        case .unavailable(.appleIntelligenceNotEnabled):
            throw OrderInterpretationError.modelUnavailable(
                reason: "Apple Intelligence is turned off. Turn it on in Settings to take voice orders."
            )

        case .unavailable(.modelNotReady):
            throw OrderInterpretationError.modelUnavailable(
                reason: "Apple Intelligence is still downloading. Please try again shortly."
            )

        case .unavailable:
            throw OrderInterpretationError.modelUnavailable(
                reason: "Apple Intelligence is unavailable on this device."
            )
        }
    }
}
