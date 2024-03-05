//
//  LoginView.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/29.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    @ObservedObject var memberVM: MemberViewModel
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.hex_FEFCF6)
            VStack {
                VStack {
                    Image("Mocacong")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .padding(.bottom, -20)
                    Text("mocacong .")
                        .font(.system(size: 37, weight: .bold))
                        .foregroundColor(.hex_4F4A44)
                    Text("카공? 모카콩!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.hex_4F4A44)
                        .offset(x: 31)
                }
                .offset(x: 8, y: -8)
                .padding(.bottom, 90)
                Button(action: {
                    memberVM.loginApple()
                }, label: {
                    appleDefaultIcon()
                })
            }
        }
        .ignoresSafeArea()
        .onDisappear {
            print("로그인 뷰 다운 시 멤버vm의 데이터 : ", memberVM.member)
        }
    }
    
    @ViewBuilder
    func oAuthIconTemplate(iconImage: String) -> some View {
        Image(iconImage)
            .resizable()
            .frame(width: 55, height: 55)
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    @ViewBuilder
    func appleIcon() -> some View {
        RoundedRectangle(cornerRadius: 18)
            .foregroundColor(.black)
            .frame(width: 55, height: 55)
            .overlay(
                Image(systemName: "apple.logo")
                    .foregroundColor(.white)
                    .font(.system(size: 28))
                    .offset(y: -3)
            )
    }
    
    @ViewBuilder
    func appleDefaultIcon() -> some View {
        RoundedRectangle(cornerRadius: 6.3)
            .frame(width: screenWidth * 0.8, height: 48)
            .foregroundColor(.black)
            .overlay(
                HStack {
                    Image(systemName: "apple.logo")
                        .foregroundColor(.white)
                        .font(.system(size: 19))
                        .offset(y:-1.5)
                    Text("Continue with Apple")
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                }
            )
    }
}

struct LoginView_Preview: PreviewProvider {
    static var previews: some View {
        LoginView(memberVM: MemberViewModel())
    }
}

