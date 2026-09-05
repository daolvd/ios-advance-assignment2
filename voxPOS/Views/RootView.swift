//
//  RootView.swift
//  Groceries
//
//  Created by Shuvam Shrestha on 28/8/2026.
//

import SwiftUI
import SwiftData

struct RootView: View {
    
    @StateObject private var productViewModel = ProductViewModel(repository: JSONProductRepository())
    @StateObject private var staffViewModel = StaffViewModel(repository: LocalStaffRepository())
    
    var body: some View {
        Group {
            if !staffViewModel.isOnShift {
                StaffLoginView()
            } else if productViewModel.isReady {
                HomeUiView()
            } else {
                MenuBootstrapView()
            }
        }
        .environmentObject(productViewModel)
        .environmentObject(staffViewModel)
        .task(id: staffViewModel.isOnShift) {
            guard staffViewModel.isOnShift else {
                productViewModel.reset()
                return
            }

            productViewModel.bootstrap()
        }
    }
}

/// Shown while the shift's menu is being read, and if it cannot be.
private struct MenuBootstrapView: View {

    @EnvironmentObject private var productViewModel: ProductViewModel

    var body: some View {
        VStack(spacing: 16) {
            if let errorMessage = productViewModel.errorMessage {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)

                Text(errorMessage)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Button("Try Again") {
                    productViewModel.bootstrap()
                }
                .font(.headline)
            } else {
                ProgressView()

                Text("Loading today's menu…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(32)
    }
}

#Preview {
    RootView()
    //    .modelContainer(for: Product.self, inMemory: true)
}
