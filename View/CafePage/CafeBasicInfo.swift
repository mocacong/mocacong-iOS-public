//
//  CafeBasicInfo.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/15.
//

import SwiftUI

struct CafeBasicInfo: View {
    
    @ObservedObject var cafeVM: CafeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let roadAddress = cafeVM.cafeData.roadAddress {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text(roadAddress)
                    Spacer()
                }
            }
            if let phone = cafeVM.cafeData.phoneNumber {
                if phone != "" {
                    Button(action: {
                        callNumber(phoneNumber: phone)
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text(phone)
                                .foregroundColor(.hex_5592EE)
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(.bottom)
        .padding(.leading, 15)
        .foregroundColor(.hex_4E483C)
        .font(.system(size: 14.5))
    }
    
    private func callNumber(phoneNumber: String) {
        if let phoneURL = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        }
    }
}
