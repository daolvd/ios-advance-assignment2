//
//  GroceryView.swift
//  Groceries
//
//  Created by Shuvam Shrestha on 4/9/2026.
//

import SwiftUI
import SwiftData

struct GroceryView: View {
    
    // @Query private var groceries: [Grocery] = []
    @State private var newPlanSheetShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            
        }
    }
}

struct NewPlanView: View {
    
    @State private var title: String = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Enter New Plan", text: $title)
                } header: {
                    Text("Details")
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        addNewGroceries()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("New Plan")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
        }
        
    }
    private func addNewGroceries() {
    //    let newGroceries = Grocery(title: title)
      //  context.insert(newGroceries)
    }
}

#Preview {
    GroceryView()
}
