//
//  GroceryListView.swift
//  Groceries
//
//  Created by Shuvam Shrestha on 7/8/2026.
//

import SwiftUI
import Lottie

struct GroceryListView: View {
    
    @EnvironmentObject private var productViewModel: ProductViewModel
    
    var body: some View {
        NavigationStack {
                List {
                    ForEach($productViewModel.products) { product in
                        ProductView(product: product)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add", systemImage: "plus") {
                            productViewModel.add(Product(title: "Banana"))
                        }
                    }
                }
            
        
            
        }
    }
}

#Preview {
    GroceryListView()
}
