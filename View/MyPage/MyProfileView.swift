//
//  MyProfile.swift
//  mocacong
//
//  Created by Suji Lee on 2023/04/18.
//

import SwiftUI
import PhotosUI

struct MyProfileView: View {
        
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var myVM: MyViewModel
    @State var showImageEditModal: Bool = false
    @State var cachedProfileImageData: Data?

    var body: some View {
        VStack(spacing: 15) {
            VStack {
                if myVM.isFetchingProfileImage == false {
                    if let imageData = myVM.profileImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth * 0.4, height: screenWidth * 0.4)
                            .clipShape(Circle())
                            .clipped()
                            .overlay {
                                Circle()
                                    .stroke(Color.hex_828282, lineWidth: 0.3)
                            }
                    } else {
                        Image("noProfile")
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenWidth * 0.4, height: screenWidth * 0.4)
                            .clipShape(Circle())
                            .clipped()
                    }
                } else {
                    ProgressView()
                        .frame(width: screenWidth * 0.4, height: screenWidth * 0.4)
                }
            }
            .overlay(
                HStack {
                    Spacer()
                    Button(action: {
                        showImageEditModal = true
                    }, label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.hex_8C9F75)
                            .background(Color.white, in: Circle())
                            .clipped()
                    })
                    .offset(y: 50)
                }
            )
            Text(myVM.myProfileData.nickname ?? "???")
                .foregroundStyle(Color.hex_483F30)
                .font(.system(size: 18, weight: .medium))
                .padding(.bottom, 7)
        }
        .padding(.bottom)
        .onAppear {
            print("MyProfileView onAppear's hasFetchedPrifleData : ", hasFetchedProfileData)
            if !hasFetchedProfileData {
                if let token = TokenManager.shared.getToken() {
                    myVM.fetchMyProfileData(accessToken: token)
                }
                hasFetchedProfileData = true
            }
        }
        .sheet(isPresented: $showImageEditModal, content: {
            ImageEditModal(memberVM: memberVM, myVM: myVM, profileImageData: $myVM.profileImageData)
                .presentationDetents([.large, .fraction(0.75)])
        })
    }
}
