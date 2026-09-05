//
//  ProductView.swift
//  Groceries
//
//  Created by Shuvam Shrestha on 7/8/2026.
//

import SwiftUI
import Lottie

struct ProductView: View {
    
    @Binding var product: Product
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let image = product.image {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            VStack(alignment: .leading) {
                Text(product.title)
              
                   
                if let description = product.description {
                    HStack(alignment: .top) {
                        Image(systemName: "pencil.and.list.clipboard")
                        Text(description)
                    }
                    .font(.caption)
                    .padding(.top, 4)
                    .foregroundStyle(Color.secondary)
                  
                    
                }
            }
            Spacer()
            Button {
                withAnimation {
                    //product.isPurchased.toggle()
                }
            } label: {
               
            }
        }
       // .strikethrough(product.isPurchased)
    }
}


