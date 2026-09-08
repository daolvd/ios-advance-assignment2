//
//  Product.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation

/// Something the till can sell today.
///
/// A product is reference data: it comes from the menu, is read fresh at the start
/// of every shift, and is never edited from inside an order. That is why an order
/// line keeps only ``id`` — the picture, the wording and the price stay here, so
/// correcting the menu corrects every screen at once.
///
/// The property names match `Resources/SampleProducts.json` exactly. There are no
/// custom `CodingKeys`: when a backend is added, that repository maps its own column
/// names rather than pushing them onto the domain.
struct Product: Identifiable, Codable, Equatable {

    var id: String = UUID().uuidString

    /// The name printed on the menu, and the name the staff and the model must both
    /// use. Matching happens on this, so its spelling is load-bearing.
    var title: String

    /// What is in it. Shown to the staff, and given to the on-device model, which
    /// needs the ingredients to tell a chicken burger from chicken nuggets.
    var description: String?

    /// Asset name for the picture, or `nil` for a product with no artwork.
    var image: String?

    /// `false` when the kitchen has run out. Sold out products are still on the menu,
    /// so the till can say what it cannot sell, but they never reach an order.
    var isAvailable: Bool = true

    /// What the customer is charged, per unit. The single source of truth for money:
    /// no caller, and certainly no language model, may supply a price.
    var price: Decimal = 0

    /// The only changes the kitchen can make to this product, such as "No Cheese".
    /// Anything asked for that is not in this list is refused and reported, never
    /// applied quietly.
    var allowModifier : [String] = []

}

