//
//  ORDER.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation
import SwiftData

/// One customer's order, from the first line put on it until it is paid for.
///
/// An order is the only thing in the app that becomes money, so it is the one thing
/// with rules around who may change it and when. It is created as a draft, edited
/// freely through ``ReviseOrderUseCase`` while the staff and customer agree on it,
/// and closed to editing the moment a payment is approved — after that, changing it
/// would leave the ticket and the takings disagreeing.
///
/// It arrives the same way whether it was spoken or typed by hand. Only the three
/// speech fields distinguish the two, and they are optional for exactly that reason.
@Model
class Order {

        /// Identifies this order for the life of the system. Never shown to anyone:
        /// ``orderNumber`` is what gets called across the counter.
        var orderID: String = UUID().uuidString

        /// The number the order is called by, 0 to 999 and then round again. Short
        /// enough to shout over a busy room; see ``OrderNumbering``.
        var orderNumber: Int

        /// `draft` while it can still be changed, `paid` once money has been taken.
        var status: String

        /// What the customer said, when the order came from speech. `nil` for an
        /// order entered by hand. Kept so the staff can show the customer their own
        /// words if a line is queried.
        var spokenText: String?

        /// The language the customer ordered in, when it was detected.
        var detectedLanguage: String?

        /// How clearly the speech was heard, 0 to 1, when the order came from speech.
        var recognitionConfidence: Double?

        /// What the customer owes, recalculated after every change to ``items``.
        /// Stored rather than computed so a paid order keeps the figure it was
        /// actually charged, even if the menu price changes afterwards.
        var orderTotal: Decimal

        var createdAt: Date

        /// When payment was approved. `nil` while the order is still open.
        var confirmedAt: Date?

        /// The lines on the ticket. Deleting the order deletes them with it — a line
        /// has no meaning apart from the order it belongs to.
        @Relationship(deleteRule: .cascade, inverse: \OrderItem.order)
        var items: [OrderItem] = []

        init(
          
            orderNumber: Int,
            status: String = "draft",
            orderTotal: Decimal = 0,
            createdAt: Date = Date()
        ) {
            self.orderNumber = orderNumber
            self.status = status
            self.orderTotal = orderTotal
            self.createdAt = createdAt
        }
}

/// One line on the ticket: how many of a product, made which way, at what price.
///
/// A line copies what it needs from the ``Product`` at the moment it is added rather
/// than pointing at the live menu, because the price charged must not move when a
/// manager edits the menu later. ``menuItemID`` is kept so the picture and the
/// allowed options can still be looked up from today's menu for display.
///
/// Two lines for the same product with the same options never coexist —
/// ``ReviseOrderUseCase`` merges them, since a cook should not be handed the same
/// item twice and asked to add it up.
@Model
class OrderItem {

        var orderItemID: String = UUID().uuidString

        /// Which product this line is, as `Product.id`. The link back to the menu.
        var menuItemID: String

        /// The product name as it was when ordered, so an old ticket still reads
        /// correctly after the menu is renamed.
        var itemName: String

        /// How many. Never less than one: a line of nothing would be cooked and
        /// never charged for.
        var quantity: Int

        /// The changes the kitchen is making to this line, each one taken from that
        /// product's `allowModifier`. Anything else was refused and reported.
        var modifiers: [String]

        /// The price of one, copied from the menu when the line was created.
        var unitPrice: Decimal

        /// ``unitPrice`` times ``quantity``, kept in step by whoever changes either.
        var lineTotal: Decimal

        var order: Order?

        init(
            menuItemID: String,
            itemName: String,
            quantity: Int,
            modifiers: [String] = [],
            unitPrice: Decimal
        ) {
            
            self.menuItemID = menuItemID
            self.itemName = itemName
            self.quantity = quantity
            self.modifiers = modifiers
            self.unitPrice = unitPrice
            self.lineTotal = unitPrice * Decimal(quantity)
        }
}
