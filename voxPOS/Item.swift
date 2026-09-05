//
//  Item.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
