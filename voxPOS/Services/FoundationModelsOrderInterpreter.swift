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
/// The model is not asked to write product names freely. It is given a schema built
/// from today's menu, so the only names it *can* produce are ones that really exist —
/// left to write freely it returns "Chicken Burger" for "Crispy Chicken Burger" and
/// folds options into names ("Large Fries"), and neither can be matched afterwards.
struct FoundationModelsOrderInterpreter: OrderInterpreting {

    /// The model's standing rules, kept in `Resources/OrderInterpreterInstructions.txt`
    /// so the wording can be edited without touching this file.
    ///
    /// Read once and held, because it is the same for every order. It is the trusted
    /// half of what the model is told — what a customer said always goes in the
    /// prompt, never in here.
    private static let instructions: String? = {
        guard let url = Bundle.main.url(
            forResource: "OrderInterpreterInstructions",
            withExtension: "txt"
        ) else {
            return nil
        }

        return try? String(contentsOf: url, encoding: .utf8)
    }()

    func interpret(text: String, menu: [Product]) async throws -> [InterpretedOrderLine] {
        try checkModelIsUsable()

        guard let instructions = Self.instructions else {
            throw OrderInterpretationError.instructionsMissing
        }

        let onSale = menu.filter(\.isAvailable)

        guard !onSale.isEmpty else {
            throw OrderInterpretationError.nothingOnTheMenu
        }

        let session = LanguageModelSession(instructions: instructions)

        let prompt = """
        MENU (name | price | options):
        \(Self.menuDescription(for: onSale))

        The customer said:
        "\(text)"
        """

        do {
            let response = try await session.respond(
                to: prompt,
                schema: try Self.schema(for: onSale)
            )

            return try Self.orderLines(from: response.content)
        } catch let error as OrderInterpretationError {
            throw error
        } catch {
            throw OrderInterpretationError.interpretationFailed(reason: error.localizedDescription)
        }
    }

    // MARK: - The menu, written for the model

    /// Sold out products never reach the model, so it cannot put one in an order.
    private static func menuDescription(for products: [Product]) -> String {
        products.map { product in
            let price = product.price.formatted(.currency(code: "AUD"))
            let modifiers = product.allowModifier.isEmpty
                ? "none"
                : product.allowModifier.joined(separator: ", ")

            return "\(product.title) | \(price) | options: \(modifiers)"
        }
        .joined(separator: "\n")
    }

    /// Builds the answer shape from today's menu.
    ///
    /// `anyOf` is what makes the names usable: the model picks from this list rather
    /// than writing prose, so every name comes back spelled exactly as the menu spells it.
    private static func schema(for products: [Product]) throws -> GenerationSchema {
        let productNames = products.map(\.title) + [InterpretedOrderLine.notOnMenu]
        let modifiers = Array(Set(products.flatMap(\.allowModifier))).sorted()

        let line = DynamicGenerationSchema(
            name: "OrderLine",
            properties: [
                .init(
                    name: "productName",
                    schema: DynamicGenerationSchema(name: "ProductName", anyOf: productNames)
                ),
                .init(
                    name: "customerWords",
                    schema: DynamicGenerationSchema(type: String.self)
                ),
                .init(
                    name: "quantity",
                    schema: DynamicGenerationSchema(type: Int.self, guides: [.minimum(1)])
                ),
                .init(
                    name: "modifiers",
                    schema: DynamicGenerationSchema(
                        arrayOf: DynamicGenerationSchema(name: "Modifier", anyOf: modifiers)
                    )
                )
            ]
        )

        let root = DynamicGenerationSchema(
            name: "Order",
            properties: [
                .init(name: "items", schema: DynamicGenerationSchema(arrayOf: line))
            ]
        )

        return try GenerationSchema(root: root, dependencies: [])
    }

    private static func orderLines(from content: GeneratedContent) throws -> [InterpretedOrderLine] {
        let items = try content.value([GeneratedContent].self, forProperty: "items")

        return try items.map { item in
            InterpretedOrderLine(
                productName: try item.value(String.self, forProperty: "productName"),
                customerWords: try item.value(String.self, forProperty: "customerWords"),
                quantity: try item.value(Int.self, forProperty: "quantity"),
                modifiers: try item.value([String].self, forProperty: "modifiers")
            )
        }
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
