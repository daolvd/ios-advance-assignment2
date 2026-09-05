//
//  RootView.swift
//  Groceries
//
//  Created by Shuvam Shrestha on 28/8/2026.
//

import SwiftUI
import SwiftData

struct RootView: View {
    
    @StateObject private var productViewModel = ProductViewModel(repository: LocalProductRepository())
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                GroceryView()
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
        .environmentObject(productViewModel)
    }
}

#Preview {
    RootView()
        .modelContainer(for: Grocery.self, inMemory: true)
}
