//
//  MyFavorite.swift
//  mocacong
//
//  Created by Suji Lee on 2023/04/18.
//

import SwiftUI

struct MyFavoriteList: View {
    
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var myVM: MyViewModel = MyViewModel()
    @ObservedObject var cafeVM: CafeViewModel
    
    var body: some View {
        VStack {
            //헤더
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("즐겨찾는 카페")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.hex_4E483C)
                    Text("즐겨찾기 한 카페를 한 눈에 확인해보세요")
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
                ForEach(myVM.myFavoriteCafeArray, id: \.self) { cafe in
                    FavoriteCafeCard(cafe: cafe)
//                        .onAppear {
//                            print(cafe.name, cafe.mapId)
//                        }
                }
                //더보기
                if let isEnd = myVM.myFavoriteData.isEnd, isEnd == false {
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
                            .padding(.leading, 8)
                    })
                }
            }
            .listStyle(PlainListStyle())
            .padding(.leading, -10)
        }
        .onAppear {
            myVM.resetList()
            if let token = TokenManager.shared.getToken() {
                myVM.fetchMyFavorite(accessToken: token, page: 0)
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
    func FavoriteCafeCard(cafe: Cafe) -> some View {
        HStack {
            //바로가기 버튼
            NavigationLink(destination: {
                CafePageView(memberVM: memberVM, cafeVM: cafeVM, myVM: myVM, cafeMapIdFromMyPage: cafe.mapId)
            }, label: {
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
                            let roundedScore = String(format: "%.0f", round(cafe.score ?? 0))
                            Image("Mocacong")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                            Text("X " + roundedScore)
                                .font(.system(size: 17))
                        }
                        //스터디타입
                        HStack(spacing: 5) {
                            if let studyType = cafe.studyType {
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
                .padding(.leading)
            })
        }
        .padding(.vertical, 20)
    }
    
    func loadMoreList() {
        if let token = TokenManager.shared.getToken(), let isEnd = myVM.myFavoriteData.isEnd, isEnd == false {
            myVM.loadMoreList(accessToken: token, tab: .favorite)
        }
    }
}


#Preview {
    MyFavoriteList(memberVM: MemberViewModel(), myVM: MyViewModel(), cafeVM: CafeViewModel())
}
