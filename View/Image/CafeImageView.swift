//
//  CageImageView.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/15.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct CafeImageView: View {
    
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var cafeVM: CafeViewModel
    @StateObject var imageVM: ImageViewModel = ImageViewModel()
    @Environment(\.dismiss) private var dismiss
    @State var showCafeImageModal: Bool = false
    @State var showImageEditModal: Bool = false
    @State var selectedImage: CafeImage? = nil
    
    var body: some View {
        NavigationView {
                VStack(spacing: -4) {
                    //헤더
                    VStack(spacing: 10) {
                        Text(cafeVM.cafeData.name ?? "상호 불명")
                            .foregroundStyle(Color.hex_483F30)
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 5.5)
                            .padding(.bottom, 4.5)
                            .overlay(alignment: .bottom, content: {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.hex_4F4A44)
                                    .frame(height: 1.3)
                            })
                        Text(cafeVM.cafeData.roadAddress ?? "주소 불명")
                            .font(.system(size: 16))
                            .foregroundColor(.hex_5C4726)
                    }
                    .frame(width: screenWidth)
                    .padding(.vertical, 20)
                    .padding(.bottom, 10)
                    .background(Color.hex_C2B8AF.opacity(0.2))
                    //
                    VStack {
                        if imageVM.cafeImageArray.isEmpty {

                        } else {
                                ScrollView {
                                    LazyVGrid(columns: [
                                        GridItem(.flexible()),
                                        GridItem(.flexible())
                                    ], spacing: 2) {
                                        ForEach(imageVM.cafeImageArray, id: \.id) { image in
                                            imageBlock(image: image)
                                                .padding(.bottom, 2)
                                        }
                                    }
                                    if let isEnd = imageVM.cafeImageReview.isEnd, isEnd == false {
                                        Button(action: {
                                            loadMorePhotos()
                                        }, label: {
                                            RoundedRectangle(cornerRadius: 5)
                                                .frame(width: screenWidth * 0.9, height: 55)
                                                .foregroundColor(Color.hex_8C9F75.opacity(0.4))
                                                .overlay (
                                                    Text("더보기")
                                                        .font(.system(size: 15.5, weight: .semibold))
                                                )
                                        })
                                    }
                                }
                            
                        }
                    }
                    Spacer()
                }
        }
        .background(Color.hex_FEFCF6)
        .onAppear {
            if let token = TokenManager.shared.getToken() {
                imageVM.fetchCafeReviewImageData(accessToken: token, mapId: cafeVM.cafeMapId, page: 0)
            }
        }
        .onDisappear {
            if let token = TokenManager.shared.getToken() {
                imageVM.fetchCafeReviewImageData(accessToken: token, mapId: cafeVM.cafeMapId, page: 0)
            }
        }
        .sheet(item: $selectedImage) { image in
            CafeImageEditModal(memberVM: memberVM, cafeVM: cafeVM, imageVM: imageVM, reviewImageToUpdate: image)
                .presentationDetents([.large, .fraction(0.65)])
        }
        .sheet(isPresented: $showCafeImageModal) {
            CafeImageModal(memberVM: memberVM, cafeVM: cafeVM, imageVM: imageVM)
                .presentationDetents([.large, .fraction(0.7)])
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing, content: {
                Button(action: {
                    showCafeImageModal = true
                }, label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 17))
                        .foregroundColor(.hex_4E483C)
                })
            })
        }
    }
    
    @ViewBuilder
    func imageBlock(image: CafeImage) -> some View {
        ZStack {
            WebImage(url: URL(string: image.imageUrl))
                .placeholder(content: {
                    ProgressView()
                })
                .resizable()
                .scaledToFill()
                .frame(width: screenWidth / 2, height: screenWidth / 2)
                .clipped()
            if image.isMe == true {
                VStack {
                    Spacer()
                    Button(action: {
                        selectedImage = image
                    }, label: {
                        Text("수정하기")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                            .frame(width: 70, height: 24)
                            .background(Color.hex_8C9F75.opacity(0.55), in: RoundedRectangle(cornerRadius: 5))
                    })
                    .padding(.bottom, 10)
                }
            }
        }
    }
    
    func loadMorePhotos() {
        if let token = TokenManager.shared.getToken(), let isEnd = imageVM.cafeImageReview.isEnd, isEnd == false {
            imageVM.loadMorePhotos(accessToken: token, cafeVM: cafeVM)
        }
    }
}
