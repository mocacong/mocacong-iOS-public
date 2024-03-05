//
//  CafePreview.swift
//  mocacong
//
//  Created by Suji Lee on 2023/05/16.
//

import SwiftUI

struct CafePreviewModal: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var cafeVM: CafeViewModel
    @ObservedObject var previewVM: PreviewViewModel
    @Binding var showCafePage: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 5) {
                VStack(spacing: 10) {
                    //카페 상호
                    VStack(spacing: 1) {
                        Text(cafeVM.cafeData.name ?? "상호 불명")
                            .foregroundStyle(Color.hex_483F30)
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 5.5)
                            .padding(.bottom, 4.5)
                            .overlay(alignment: .bottom, content: {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.hex_4F4A44)
                                    .frame(height: 1.1)
                            })
                    }
                    //도로명 주소
                    Text(cafeVM.cafeData.roadAddress ?? "주소 불명")
                        .font(.system(size: 15))
                        .foregroundColor(.hex_5C4726)
                }
                .frame(width: screenWidth)
                .padding(.vertical)
//                .background(Color.hex_C2B8AF.opacity(0.2))
                .padding(.bottom, 20)
                //상세 정보
                VStack(spacing: 15){
                    //리뷰 개수
                    HStack {
                        Text("리뷰 개수")
                        Spacer()
                        Text("\(previewVM.cafePreviewData.reviewsCount ?? 0)" + "개")
                    }
                    //평점
                    HStack(spacing: 2) {
                        Text("평점")
                        Spacer()
                        let roundedScore = String(format: "%.0f", round(previewVM.cafePreviewData.score ?? 0))
                        Image("Mocacong")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 22)
                        Text("X " + roundedScore)
                    }
                    //스터디 타입
                    HStack(spacing: 13) {
                        Text("스터디 타입")
                        Spacer()
                        if previewVM.cafePreviewData.studyType == "solo" {
                            StudyTypeLabel(type: "혼자")
                        } else if previewVM.cafePreviewData.studyType == "group" {
                            StudyTypeLabel(type: "같이")
                        } else if previewVM.cafePreviewData.studyType == "both" {
                            StudyTypeLabel(type: "혼자")
                            StudyTypeLabel(type: "같이")
                        }
                    }
                }
                .background(Color.white)
                .foregroundColor(.hex_483F30)
                .padding(.horizontal)
            }
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.height < 0 {
                        // 위로 스와이프할 때의 동작
                        withAnimation {
                            showCafePage = true
                            dismiss()
                        }
                    }
                }
        )
        .onTapGesture {
            showCafePage = true
            dismiss()
        }

    }
    
    @ViewBuilder
    func StudyTypeLabel(type: String) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 57, height: 27)
            .foregroundColor(.hex_C2B8AF)
            .overlay(
                Text(type)
                    .foregroundStyle(.white)
                    .font(.system(size: 15, weight: .medium))
            )
    }
}
