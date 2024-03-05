//
//  CafeHeaderView.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/15.
//

import SwiftUI

struct CafeHeader: View {
    
    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
    
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var cafeVM: CafeViewModel
    @ObservedObject var imageVM: ImageViewModel
    @State var isFavorite: Bool = false
    @State var showEditModal: Bool = false
    @State var isPostingStar: Bool = false
    
    var body: some View {
        VStack {
            // 카페 이미지 그리드
            NavigationLink(destination: {
                CafeImageView(memberVM: memberVM, cafeVM: cafeVM)

            }, label: {
                CafeImageGrid(memberVM: memberVM, cafeVM: cafeVM, imageVM: imageVM)
            })
            // 카페 타입
            HStack(spacing: 5) {
                Spacer()
                if let studyType = cafeVM.cafeData.studyType {
                    if studyType == "solo" || studyType == "both" {
                        StudyTypeLabel(type: "혼자")

                    }
                    if studyType == "group" || studyType == "both" {
                        StudyTypeLabel(type: "같이")

                    }
                }
            }
            .padding(.trailing, 12)
            .foregroundColor(.black)
            .font(.system(size: 15))
            // 카페 상호
            if let cafeName = cafeVM.cafeData.name, cafeName == "스테인드커피로스터스" {
                Text("""
                \(cafeName)
                     (카페온더플랜)
                """)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.hex_483F30)
                    .padding(.vertical, 6)
            } else {
                Text(cafeVM.cafeData.name ?? "상호 불명")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.hex_483F30)
                    .padding(.vertical, 6)
            }
            // 카페 정보
            VStack(spacing: 6) {
                if let score = cafeVM.cafeData.score {
                    let displayScore = String(format: "%.1f", score)
                    let roundedScore = String(format: "%.0f", round(score))
                    // 카페 정보
                    HStack() {
                        Text(displayScore + " / 5")
                            .font(.system(size: 15, weight: .bold))
                            .padding(.trailing)
                        if let reviewsCount = cafeVM.cafeData.reviewsCount {
                            Text("리뷰 " + reviewsCount.description + "개")
                        }
                        if let commentCount = cafeVM.cafeData.commentsCount {
                            Text("댓글 " + commentCount.description + "개")
                        }
                    }
                    .font(.system(size: 15))
                    .foregroundColor(.hex_4E483C)
                    // 평점 콩
                    HStack(spacing: 0.2) {
                        ForEach(0..<5) { index in
                            Image(index + 1 > Int(roundedScore) ?? 0 ? "MocacongNil" : "Mocacong")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 31.5)
                        }
                    }
                } else {
                    HStack(spacing: 0.2) {
                        ForEach(0..<5) { index in
                            Image("MocacongNil")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 31.5)
                        }
                    }
                }
            }
            // 리뷰 편집 및 좋아요 버튼
            ActionButtons()
        }
        .sheet(isPresented: $showEditModal) {
            CafeReviewModal(memberVM: memberVM, cafeVM: cafeVM)
        }
    }
    @ViewBuilder
    func StudyTypeLabel(type: String) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 57, height: 27)
            .foregroundColor(.hex_C2B8AF)
            .overlay(
                Text(type)
                    .foregroundStyle(Color.hex_4F4A44)
                    .font(.system(size: 15, weight: .medium))
            )
    }
    
    @ViewBuilder
    func ActionButtons() -> some View {
        HStack(spacing: 10) {
            Button(action: {
                // 진동 발생
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()

                if let token = TokenManager.shared.getToken() {
                    if cafeVM.cafeData.favorite == false && !self.isPostingStar {
                        starCafe(accessToken: token, mapId: cafeVM.cafeMapId)
                    } else if cafeVM.cafeData.favorite == true {
                        deleteStar(accessToken: token, mapId: cafeVM.cafeMapId)
                    }
                }
            }, label: {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.hex_958B7C, lineWidth: 0.5)
                    .foregroundColor(.white)
                    .frame(width: 70, height: 30)
                    .overlay(
                        Image(systemName: cafeVM.cafeData.favorite == true ? "heart.fill" : "heart")
                            .foregroundColor(.hex_B86A6A)
                            .font(.system(size: 20))
                    )
            })
            Button(action: {
                showEditModal = true
            }, label: {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.hex_958B7C, lineWidth: 0.5)
                    .foregroundColor(.white)
                    .frame(width: 70, height: 30)
                    .overlay(
                        Image("EditPencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 19)
                            .offset(y: -0.5)
                    )
            })
        }
    }
    
    @ViewBuilder
    func hightlightText(text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.hex_4E483C)
    }
    
    func deleteStar(accessToken: String, mapId: String) {
        cafeVM.deleteStarData(accessToken: accessToken, mapId: mapId)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("즐겨찾기 삭제 비동기 처리 error: \(error)")
                case .finished:
                    print("즐겨찾기 삭제 비동기 처리 완료")
                    break
                }
            }, receiveValue: { data in
            })
            .store(in: &cafeVM.cancellables)
    }
    
    func starCafe(accessToken: String, mapId: String) {
        self.isPostingStar = true
        cafeVM.StarCafeData(accessToken: accessToken, mapId: mapId)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("즐겨찾기 저장 비동기 처리 error: \(error)")
                case .finished:
                    print("즐겨찾기 저장 비동기 처리 완료")
                    self.isPostingStar = false
                    break
                }
            }, receiveValue: { data in
            })
            .store(in: &cafeVM.cancellables)
    }
}

