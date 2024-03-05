//
//  MyProfileInCommentModal.swift
//  mocacong
//
//  Created by Suji Lee on 12/7/23.
//

import SwiftUI
import PhotosUI

struct MyProfileInCommentModal: View {
    
    @ObservedObject var myVM: MyViewModel
    var imageSize: CGFloat = 61
    
    var body: some View {
        VStack(spacing: 3) {
            VStack {
                if let imageData = myVM.profileImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(Circle())
                        .clipped()
                        .overlay {
                            Circle()
                                .stroke(Color.hex_A49E99, lineWidth: 0.2)
                        }
                } else {
                    Image("noProfile")
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(Circle())
                        .clipped()
                }
            }
            Text(myVM.myProfileData.nickname ?? "???")
                .foregroundStyle(Color.hex_483F30)
                .font(.system(size: 14, weight: .medium))
        }
        .onAppear {
            if let token = TokenManager.shared.getToken() {
                myVM.fetchMyProfileData(accessToken: token)
            }
        }
    }
}
