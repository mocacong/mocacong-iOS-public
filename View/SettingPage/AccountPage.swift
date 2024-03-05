//
//  AcountPage.swift
//  mocacong
//
//  Created by Suji Lee on 2023/07/09
//

import SwiftUI

struct AcountPage: View {
    
    @ObservedObject var stateManager = StateManager.shared
    @ObservedObject var tokenManager = TokenManager.shared
    
    @ObservedObject var myVM: MyViewModel
    @ObservedObject var memberVM: MemberViewModel
    @State private var showAlert = false
    @State var showLogoutAlert: Bool = false
    
    var body: some View {
            VStack {
                HStack {
                    Text("계정 정보")
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                        .padding(.leading)
                    Spacer()
                }
                .padding(.top, 70)
                .padding(.bottom, 30)
                HStack {
                    Text("이메일")
                    Spacer()
                    Text(myVM.myProfileData.email ?? "")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                HStack {
                    Text("로그인 플랫폼")
                    Spacer()
//                    Text(memberVM.member.platform ?? "")
                    Text("Apple")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                Divider()
                    .padding(.vertical)
                HStack {
                    Text("로그아웃 및 회원탈퇴")
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                        .padding(.leading)
                    Spacer()
                }
                HStack(spacing: 60) {
                    Button(action: {
                        showLogoutAlert = true
                    }, label: {
                        Text("로그아웃")
                            .font(.callout)
                            .padding(.top, 30)
                            .foregroundColor(.blue)
                    })
                    Button(action: {
                        showAlert = true
                    }, label: {
                        Text("회원탈퇴")
                            .font(.callout)
                            .padding(.top, 30)
                            .foregroundColor(.red)
                    })
                }
                Spacer()
            }
            .alert("알림", isPresented: $showLogoutAlert, actions: {
                Button(action: {
                    tokenManager.logoutUser()
                }, label: {
                    Text("확인")
                })
            }, message: {
                    Text("로그아웃 하시겠습니까?")
            })
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("회원 탈퇴"),
                message: Text("프로필, 즐겨찾기한 카페, 리뷰한 카페, 코멘트한 카페의 목록이 사라집니다"),
                primaryButton: .destructive(Text("취소")),
                secondaryButton: .cancel(Text("탈퇴"),action: {
                    stateManager.isAgreed = false
                    if let token = memberVM.member.token {
                        memberVM.deleteMember(accessToken: token)
                    }
                }))
        }
    }
}
