//
//  HomeUiView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI

struct HomeUiView: View {

    @EnvironmentObject private var staffViewModel: StaffViewModel
    @State private var isConfirmingEndShift = false
    @State private var isTakingVoiceOrder = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header
            HStack {
   
                Spacer()

                Button("End Shift") {
                    isConfirmingEndShift = true
                }
                .font(.headline)
            }

            // Title
            Text("New order")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 26)

            Text(staffViewModel.shiftCaption)
                .font(.title3)
                .foregroundStyle(.secondary)
                .padding(.top, 4)

      
     

            // Voice Order
            Button {
                isTakingVoiceOrder = true
            } label: {
                HStack(spacing: 28) {
                    VStack{
                        Image(systemName: "waveform")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.blue)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Start listening")
                                .font(.system(size: 16))
                                .foregroundStyle(.secondary)

                       
                        }
                    }
                
                    Text("Voice Order")
                        .font(.title2.bold())
                        .foregroundStyle(.primary)

                    Image(systemName: "chevron.right")
                        .font(.title3.bold())
                        .foregroundStyle(.blue)
                }
                .padding(.horizontal, 26)
                .frame(maxWidth: .infinity, minHeight: 120)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.separator), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 60)
            // Manual Order
            Button {
                // TODO
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Manual Order")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)

                        Text("Pick items from the menu")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 26)
                .frame(maxWidth: .infinity, minHeight: 120)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.separator), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 28)

            // Next order
            Text("Next order · #43")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(Capsule())
                .padding(.top, 44)

            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.top, 24)
        .background(Color(.systemBackground))
        .fullScreenCover(isPresented: $isTakingVoiceOrder) {
            VoiceOrderUiView()
        }
        .confirmationDialog(
            "End this shift?",
            isPresented: $isConfirmingEndShift,
            titleVisibility: .visible
        ) {
            Button("End Shift", role: .destructive) {
                staffViewModel.endShift()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You will need to sign in again to take new orders.")
        }
    }
}

#Preview {
    HomeUiView()
        .environmentObject(StaffViewModel(repository: LocalStaffRepository()))
}
