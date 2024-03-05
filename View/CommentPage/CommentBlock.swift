//
//  CommentBlock.swift
//  mocacong
//
//  Created by Suji Lee on 2023/05/27.
//

import SwiftUI

struct CommentBlock: View {
    
    @ObservedObject var myVM: MyViewModel
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.hex_B0A091)
            .frame(width: screenWidth * 0.95, height: 50)
            .overlay (
                HStack {
                    VStack {
                        if let imageData = myVM.profileImageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 37)
                                .clipShape(Circle())
                                .overlay {
                                    Circle()
                                        .stroke(Color.hex_828282, lineWidth: 0.3)
                                }
                        } else {
                            Image("noProfile")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 37)
                                .clipShape(Circle())
                        }
                    }
                    Text("\(myVM.myProfileData.nickname ?? "")님의 댓글 쓰기")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                    .padding(.horizontal)
            )
            .onAppear {
                if let token = TokenManager.shared.getToken() {
                    myVM.fetchMyProfileData(accessToken: token)
                }
            }
    }
}

