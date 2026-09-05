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
    @StateObject private var staffViewModel = StaffViewModel(repository: LocalStaffRepository())
    
    var body: some View {
        Group {
            if staffViewModel.isOnShift {
          
                HomeUiView()
            
            } else {
                StaffLoginView()
            }
        }
        .environmentObject(productViewModel)
        .environmentObject(staffViewModel)
    }
}

#Preview {
    RootView()
    //    .modelContainer(for: Product.self, inMemory: true)
}
