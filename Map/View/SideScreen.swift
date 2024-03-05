//
//  SideScreen.swift
//  mocacong
//
//  Created by Suji Lee on 10/23/23.
//

import SwiftUI

enum Tab {
    case favorite
    case review
    case comment
}

struct SideScreen: View {
    
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var myVM: MyViewModel
    @ObservedObject var cafeVM: CafeViewModel
    @Binding var openSideScreen: Bool
    
    var version: String = "2.2.1"

    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Rectangle()
                    .frame(width: screenWidth * 0.66)
                    .foregroundColor(.white)
                VStack {
                    //dismiss 버튼
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                openSideScreen = false
                            }
                        }, label: {
                            Image("Menu")
                        })
                    }
                    .padding(.trailing, 20)
                    // 프로필
                    VStack {
                        if myVM.profileDataFetched {
                            MyProfileView(memberVM: memberVM, myVM: myVM)
                        } else {
                            Text("사용자 프로필 조회 실패")
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 11)
                    //마이페이지, 설정
                    VStack(alignment: .leading, spacing: 35) {
                        // 마이페이지 리스트
                        VStack(alignment: .leading, spacing: 35) {
                            //즐겨찾기 목록
                            NavigationLink(destination: {
                                MyFavoriteList(memberVM: memberVM, myVM: myVM, cafeVM: cafeVM)
                            }, label: {
                                HStack(spacing: 16) {
                                    Image(systemName: "arrowtriangle.right.fill")
                                        .font(.system(size: 10))
                                    Text("즐겨찾기 목록")
                                }
                            })
                            //내가 리뷰한 카페
                            NavigationLink(destination: {
                                MyReviewList(memberVM: memberVM, myVM: myVM, cafeVM: cafeVM)
                            }, label: {
                                HStack(spacing: 16) {
                                    Image(systemName: "arrowtriangle.right.fill")
                                        .font(.system(size: 10))
                                    Text("리뷰 카페 목록")
                                }
                            })
                            //작성 댓글 목록
                            NavigationLink(destination: {
                                MyCommentList(memberVM: memberVM, myVM: myVM, cafeVM: cafeVM)
                            }, label: {
                                HStack(spacing: 16) {
                                    Image(systemName: "arrowtriangle.right.fill")
                                        .font(.system(size: 10))
                                    Text("작성 댓글 목록")
                                }
                            })
                        }
                        .foregroundColor(.hex_5C4726)
                        .font(.system(size: 17, weight: .medium))
                        .padding(.bottom, 10)
                        // 설정 리스트
                        VStack(alignment: .leading, spacing: 17) {
                            NavigationLink(destination: {
                                AcountPage(myVM: myVM, memberVM: memberVM)
                            }, label: {
                                Text("계정 정보")
                                    .foregroundColor(.hex_5C4726)
                                    .font(.system(size: 16, weight: .regular))

                            })
                            Button(action: {
                                if let url = URL(string: "https://www.notion.so/mocacong/78a169a2532a4e9e94fe2ae2da41c6a4") {
                                    UIApplication.shared.open(url)
                                }
                            }, label: {
                                Text("이용 약관")
                            })
                            Button(action: {
                                if let url = URL(string: "https://www.notion.so/mocacong/36de943075a2454d9bc3383e909c1390") {
                                    UIApplication.shared.open(url)
                                }
                            }, label: {
                                Text("위치기반 서비스 이용약관")
                            })
                            Button(action: {
                                if let url = URL(string: "https://www.notion.so/mocacong/ef1c29e4c9954d3e907936e955a1b8a0") {
                                    UIApplication.shared.open(url)
                                }
                            }, label: {
                                Text("개인정보 처리 방침")
                            })
                            Button(action: {
                                if let url = URL(string: "https://www.notion.so/mocacong/053df0bda1674234a5252d8bc82a4b7b") {
                                    UIApplication.shared.open(url)
                                }
                            }, label: {
                                Text("개인정보 수집 및 이용 동의서")
                            })
                        }
                        .foregroundStyle(Color.hex_4F4A44)
                    }
                    .padding(.bottom, 40)
                    VStack(spacing: 6) {
                        Text("버전 정보 : \(version)")
                        Text("문의 official.mocacong@gmail.com")
                    }
                    .foregroundColor(.gray.opacity(0.9))
                    .font(.system(size: 12))
                    .padding(.bottom, 10)
                }
                .padding(.top, 20)
                .foregroundColor(.hex_483F30)
                .font(.system(size: 15))
            }
            .frame(width: screenWidth * 0.65, height: screenHeight)
        }
    }
}

#Preview {
    SideScreen(memberVM: MemberViewModel(), myVM: MyViewModel(), cafeVM: CafeViewModel(), openSideScreen: .constant(true), version: "2.1.0")
}
