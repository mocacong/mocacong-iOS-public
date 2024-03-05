//
//  MyReviewPage.swift
//  mocacong
//
//  Created by Suji Lee on 2023/04/18.
//

import SwiftUI

struct MyReviewList: View {
    
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var myVM: MyViewModel = MyViewModel()
    @ObservedObject var cafeVM: CafeViewModel
    
    var body: some View {
        VStack {
            //헤더
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("나의 리뷰")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.hex_4E483C)
                        .foregroundStyle(Color.hex_4E483C)
                    Text("카페별로 작성 리뷰를 확인해볼까요?")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.hex_4F4A44)
                }
                Spacer()
            }
            .frame(width: screenWidth)
            .padding(.vertical, 30)
            .padding(.bottom, 10)
            .padding(.leading, 35)
            .background(Color.hex_C2B8AF.opacity(0.2))
            //목록
            List {
                ForEach(myVM.myReviewCafeArray, id: \.self) { cafe in
                    ReviewedCafeCard(cafe: cafe)
                        .padding(.vertical)
                        .padding(.trailing, 2)
                }
                if let isEnd = myVM.myReviewData.isEnd, isEnd == false {
                    Button(action: {
                        loadMoreList()
                    }, label: {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: screenWidth * 0.95, height: 55)
                            .foregroundColor(Color.hex_C2B8AF.opacity(0.2))
                            .overlay {
                                Text("더보기")
                                    .font(.system(size: 15.5, weight: .semibold))
                                    .foregroundColor(.hex_625D57)
                            }
                    })
                }
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            myVM.resetList()
            if let token = TokenManager.shared.getToken() {
                myVM.fetchMyReview(accessToken: token, page: 0)
            }
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
    func ReviewedCafeCard(cafe: Review) -> some View {
        HStack {
            //바로가기 버튼
            NavigationLink(destination: {
                CafePageView(memberVM: memberVM, cafeVM: cafeVM, myVM: myVM, cafeMapIdFromMyPage: cafe.mapId)
            }, label: {
                VStack(alignment: .leading) {
                    //카페 정보
                    HStack {
                        //카페 이름 및 주소
                        VStack(alignment: .leading, spacing: 3) {
                            Text(cafe.name ?? "")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(Color.hex_4E483C)
                                .offset(y: -2)
                            if let roadAddressName = cafe.roadAddress {
                                Text(roadAddressName)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(Color.hex_4F4A44.opacity(0.5))
                            }
                        }
                        Spacer()
                        //평점 및 스터디타입
                        VStack(alignment: .trailing) {
                            //평점
                            HStack(spacing: 1) {
                                let score = String(cafe.myScore ?? 0)
                                Image("Mocacong")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                Text("X " + score)
                                    .font(.system(size: 17))
                            }
                            //스터디타입
                            HStack(spacing: 3) {
                                if let studyType = cafe.myStudyType {
                                    if studyType == "solo" || studyType == "both" {
                                        StudyTypeLabel(type: "혼자")
                                    }
                                    if studyType == "group" || studyType == "both" {
                                        StudyTypeLabel(type: "같이")
                                    }
                                }
                            }
                            .font(.system(size: 13))
                            .foregroundColor(.hex_4E483C)
                        }
                    }
                    .padding(.bottom)
                    //리뷰 내용
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 20) {
                            DetailInfoCard(reviewType: "power", titleReview: cafe.myPower ?? "리뷰가 없어요")
                            DetailInfoCard(reviewType: "wifi", titleReview: cafe.myWifi ?? "리뷰가 없어요")
                            DetailInfoCard(reviewType: "toilet", titleReview: cafe.myToilet ?? "리뷰가 없어요")
                        }
                        VStack(alignment: .leading, spacing: 20) {
                            DetailInfoCard(reviewType: "desk", titleReview: cafe.myDesk ?? "리뷰가 없어요")
                            DetailInfoCard(reviewType: "sound", titleReview: cafe.mySound ?? "리뷰가 없어요")
                            DetailInfoCard(reviewType: "parking", titleReview: cafe.myParking ?? "리뷰가 없어요")
                        }
                    }
                }
                .padding(.leading, 8)
            })
            .padding(.vertical, 25)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.hex_BABABA, lineWidth: 0.4)
                    .frame(width: screenWidth * 0.96)
            }
        }
        
    }
    
    func loadMoreList() {
        if let token = TokenManager.shared.getToken(), let isEnd = myVM.myReviewData.isEnd, isEnd == false {
            myVM.loadMoreList(accessToken: token, tab: .review)
        }
    }
}
