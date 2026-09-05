//
//  OrderCompleteUIView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI
import Lottie

struct OrderCompleteUiView: View {
    
    var body: some View {
           VStack(spacing: 0) {

               Spacer()
                   .frame(height: 110)

               LottieView(animation: .named("success"))
                   .playing(loopMode: .playOnce)
                   .resizable()
                   .scaledToFit()
                   .frame(width: 120, height: 120)

               Text("PAYMENT COMPLETE")
                   .font(.caption.bold())
                   .foregroundStyle(.green)
                   .padding(.top, 30)

               Text("#43")
                   .font(.system(size: 58, weight: .bold))
                   .padding(.top, 18)

               Text("Paid $24.00 · Cash")
                   .font(.headline)
                   .foregroundStyle(.secondary)
                   .padding(.top, 14)

               Text("Returning to new order in 6 seconds")
                   .font(.subheadline)
                   .foregroundStyle(.secondary)
                   .padding(.top, 34)

               Spacer()

               Button(action: {
                   // TODO: Start new order
               }) {
                   Text("New Order")
                       .font(.headline)
                       .foregroundStyle(.white)
                       .frame(maxWidth: .infinity)
                       .frame(height: 56)
                       .background(Color.blue)
                       .clipShape(RoundedRectangle(cornerRadius: 14))
               }
           }
           .padding(.horizontal, 24)
           .padding(.bottom, 70)
           .background(Color(.systemBackground))
       }
   }

#Preview {
    OrderCompleteUiView()
}
