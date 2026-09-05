//
//  StaffLoginView.swift
//  voxPOS
//
//  Created by Van Dao Le on 5/9/2026.
//

import SwiftUI

struct StaffLoginView: View {
    var body: some View {
      
        
        VStack (alignment: .leading, spacing: 0){
                Text("Start your shift")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
                .padding(.top, 16)
                .padding(.bottom, 16)
            
                Text("Sign in to start your shift")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.blue)
                .padding(.bottom, 16)
            
            VStack (spacing : 20) {
                
                // staff name input
                    VStack(alignment: .leading, spacing: 8){
                        Text("Your Name")
                            .font(Font.system(size: 14, weight: .bold))
                            .padding(.bottom, 8)
                        
                        TextField("eg: John Doe", text: .constant(""))
                            .textContentType(.name)
                            .padding(.horizontal, 16)
                            .frame(height: 60)
                            .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color.gray.opacity(0.3),
                                            lineWidth: 1
                                        )
                                }
                    }
                // staff shift code
                    VStack(alignment: .leading, spacing: 8){
                        Text("Shift Code")
                            .font(Font.system(size: 14, weight: .bold))
                            .padding(.bottom,8)
                        
                        TextField("eg: NightShift 1", text: .constant(""))
                            .textContentType(.name)
                            .padding(.horizontal, 16)
                            .frame(height: 60)
                            .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color.gray.opacity(0.3),
                                            lineWidth: 1
                                        )
                                }
                    }
                }
            .padding(.top, 48)
          
            Spacer(minLength: 32)
            
            Button(action: startShift) {
                           Text("Start Shift")
                               .font(.system(size: 16, weight: .semibold))
                               .frame(maxWidth: .infinity)
                               .frame(height: 60)
                               .foregroundStyle(.white)
                               .background( Color.blue)
                               .clipShape(RoundedRectangle(cornerRadius: 12))
                       }
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private func startShift() {
        print("start shift")

    }
}

#Preview {
    StaffLoginView()
}
