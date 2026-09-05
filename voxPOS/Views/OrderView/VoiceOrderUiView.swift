//
//  VoiceOrderUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI
import Lottie

struct VoiceOrderUiView: View {
    var body: some View {
           VStack(alignment: .leading, spacing: 0) {


               Text("Listening")
                   .font(.title.bold())
                   .padding(.top, 20)

               Text("We’re listening for the customer.")
                   .font(.subheadline)
                   .foregroundStyle(.secondary)
                   .padding(.top, 2)

               // Lottie recorder
               LottieView(animation: .named("Red_recorder"))
                   .playing(loopMode: .loop)
                   .resizable()
                   .scaledToFit()
                   .frame(width: 170, height: 170)
                   .frame(maxWidth: .infinity)
                   .padding(.top, 40)

               // Detected language
               Text("Detected: Vietnamese")
                   .font(.caption.bold())
                   .foregroundStyle(.secondary)
                   .padding(.horizontal, 16)
                   .padding(.vertical, 8)
                   .background(Color(.secondarySystemBackground))
                   .clipShape(Capsule())
                   .frame(maxWidth: .infinity)
                   .padding(.top, 18)

               // Transcript
               VStack(alignment: .leading, spacing: 12) {
                   Text("LIVE TRANSCRIPT")
                       .font(.caption2.bold())
                       .foregroundStyle(.secondary)

                   Text("“Two chicken burgers, one without cheese.”")
                       .font(.body)
                       .foregroundStyle(.primary)
               }
               .frame(maxWidth: .infinity, alignment: .leading)
               .padding()
               .frame(minHeight: 130, alignment: .topLeading)
               .background(Color(.secondarySystemBackground))
               .clipShape(RoundedRectangle(cornerRadius: 16))
               .padding(.top, 28)

               Spacer()

               Button(action: {
                   // TODO: Stop recording
               }) {
                   Text("Stop")
                       .font(.headline)
                       .foregroundStyle(.white)
                       .frame(maxWidth: .infinity)
                       .frame(height: 54)
                       .background(Color.blue)
                       .clipShape(RoundedRectangle(cornerRadius: 14))
               }

               Button(action: {
                   // TODO: Cancel
               }) {
                   Text("Cancel")
                       .font(.headline)
                       .foregroundStyle(.secondary)
                       .frame(maxWidth: .infinity)
                       .frame(height: 50)
               }
               .padding(.top, 8)
           }
           .padding(.horizontal, 24)
           .padding(.top, 24)
           .background(Color(.systemBackground))
       }
   }

   #Preview {
       VoiceOrderUiView()
   }
