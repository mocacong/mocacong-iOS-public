//
//  CafeImageGrid.swift
//  mocacong
//
//  Created by Suji Lee on 2023/05/29.
//

import SwiftUI
import SDWebImageSwiftUI

struct CafeImageGrid: View {
    
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var cafeVM: CafeViewModel
    @ObservedObject var imageVM: ImageViewModel
    var imageHeight: CGFloat = screenWidth * 0.52
    
    var body: some View {
        HStack(spacing: 0) {
            if imageVM.cafeImageArray.isEmpty == false {
                WebImage(url: URL(string: imageVM.cafeImageArray.first?.imageUrl ?? ""))
                    .resizable()
                    .indicator(.activity)
                    .scaledToFill()
                    .frame(width: screenWidth / 2, height: imageHeight)
                    .clipped()
                    .border(Color.hex_4E483C.opacity(0.3))
            } else {
                Rectangle()
                    .stroke(Color.white, lineWidth: 1)
                    .background(Color.hex_EBE9E7, in: Rectangle())
                    .frame(width: screenWidth / 2, height: imageHeight)
                    .overlay {
                        Text("no image")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.hex_828282)
                    }
            }
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(0..<2) { index in
                        getImageView(for: index + 1)
                    }
                }
                HStack(spacing: 0) {
                    ForEach(2..<4) { index in
                        getImageView(for: index + 1)
                    }
                }
            }
        }
        .onAppear {
            if let token = TokenManager.shared.getToken() {
                imageVM.fetchCafeReviewImageData(accessToken: token, mapId: cafeVM.cafeMapId, page: 0)
            }
        }
    }
    
    @ViewBuilder
    func getImageView(for index: Int) -> some View {
        //사진 있을 경우
        if index < imageVM.cafeImageArray.count {
            WebImage(url: URL(string: imageVM.cafeImageArray[index].imageUrl))
                .resizable()
                .indicator(.activity)
                .scaledToFill()
                .frame(width: screenWidth / 4, height: imageHeight / 2)
                .clipped()
                .overlay {
                    if index == 4 {
                        NavigationLink(destination: {
                            CafeImageView(memberVM: memberVM, cafeVM: cafeVM)
                        }, label: {
                            VStack {
                                Image(systemName: "camera")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                                Text("더보기")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .bold))
                            }
                        })
                    }
                }
        } else {
            Rectangle()
                .stroke(Color.white, lineWidth: 1)
                .background(Color.hex_EBE9E7, in: Rectangle())
                .frame(width: screenWidth / 4, height: imageHeight / 2)
                .overlay {
                    if index == 4 {
                        NavigationLink(destination: {
                            CafeImageView(memberVM: memberVM, cafeVM: cafeVM)
                        }, label: {
                            VStack {
                                Image(systemName: "camera")
                                    .font(.system(size: 26))
                                Text("더보기")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.hex_625D57)
                        })
                    } else {
                        Text("no image")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.hex_828282)
                    }
                }
        }
    }
}
