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
struct FoundationModelsOrderInterpreter: OrderInterpreting {

    /// The shape the model must answer in.
    ///
    /// Held here rather than in the domain, because it exists to satisfy the model's
    /// schema, not to describe an order.
    @Generable
    struct OrderDraft {
        @Guide(description: "Every item the customer asked for, in the order they said them.")
        var items: [LineDraft]
    }

    @Generable
    struct LineDraft {
        @Guide(description: "The product name copied exactly from the menu.")
        var productName: String

        @Guide(description: "How many of this item the customer wants. At least 1.")
        var quantity: Int

        @Guide(description: "Options the customer asked for, copied exactly from that product's options. Empty if none.")
        var modifiers: [String]
    }

    func interpret(text: String, menu: String) async throws -> [InterpretedOrderLine] {
        try checkModelIsUsable()

        guard let instructions = Self.instructions else {
            throw OrderInterpretationError.instructionsMissing
        }

        let session = LanguageModelSession(instructions: instructions)
        
        // prompt
        let prompt = """
        MENU (id | name | price | options):
        \(menu)

        The customer said:
        "\(text)"
        """

        do {
            let response = try await session.respond(to: prompt, generating: OrderDraft.self)

            return response.content.items.map {
                InterpretedOrderLine(
                    productName: $0.productName,
                    quantity: $0.quantity,
                    modifiers: $0.modifiers
                )
            }
        } catch {
            throw OrderInterpretationError.interpretationFailed(reason: error.localizedDescription)
        }
    }

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
