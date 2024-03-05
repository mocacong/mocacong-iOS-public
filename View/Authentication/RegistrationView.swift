//
//  RegistrationView.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/29.


import SwiftUI
import UIKit

struct RegistrationView: View {
    
    @ObservedObject var memberVM: MemberViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State var nickname = ""
    @Binding var mocacongMemeberToRegister: Member
    @State var isDuplicated: Bool?
    @State var textInputAccepted: Bool = false
    @State var nicknameHasNumber: Bool = false
    @State var nicknameHasSpecial: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 4) {
                    Text("나만의 닉네임을 설정해주세요!")
                        .font(.system(size: 22, weight: .semibold))
                    Text("닉네임은 리뷰 댓글에 표시됩니다")
                        .foregroundColor(.hex_4E483C)
                        .font(.system(size: 16))
                }
                .padding(.bottom, 100)
                VStack(alignment: .leading, spacing: 20) {
                    //닉네임 레이블
                    HStack(spacing: 17) {
                        Text("예시) 프로카공러")
                            .font(.system(size: 15.5))
                            .foregroundColor(.black.opacity(0.7))
                        Spacer()
                    }
                    .padding(.bottom)
                    //닉네임 입력창
                    HStack {
                        Image(systemName: "quote.opening")
                            .foregroundColor(.hex_627D41)
                            .font(.system(size: 22))
                        TextField("nickname (변경 불가)", text: $nickname)
                            .font(.system(size: 17.5))
                            .padding(.leading, 7)
                            .onAppear {
                                UIApplication.shared.hideKeyboard()
                            }
                            .onChange(of: nickname, perform: { newValue in
                                checkNicknameDuplication(nickname: newValue)
                                print(newValue)
                            })
                            .onChange(of: nickname) { val in
                                //닉네임 개수 검사
                                if val.count >= 2 && val.count <= 6 {
                                    textInputAccepted = true
                                } else {
                                    textInputAccepted = false
                                }
                                //닉네임 숫자 검사
                                let numbers = CharacterSet.decimalDigits
                                nicknameHasNumber = val.unicodeScalars.contains(where: numbers.contains)
                                if nicknameHasNumber == true {
                                    textInputAccepted = false
                                } else {
                                    textInputAccepted = true
                                }
                                //닉네임 특수문자 검사
                                let specialCharacter = CharacterSet(charactersIn: " !\"#$%&'()*+,-./:;<=>?@[]^_`{|}~")
                                nicknameHasSpecial =  val.unicodeScalars.contains(where: specialCharacter.contains)
                                if nicknameHasSpecial == true {
                                    textInputAccepted = false
                                } else {
                                    textInputAccepted = true
                                }
                            }
                        Image(systemName: "quote.closing")
                            .font(.system(size: 22))
                            .foregroundColor(.hex_627D41)
                    }
                    VStack(alignment: .leading) {
                        if nickname.count < 2 || nickname.count > 6 || nicknameHasNumber == true || nicknameHasSpecial == true {
                            Text("닉네임은 한글, 영어로만 구성된 2~6자여야 합니다")
                                .font(.system(size: 13))
                                .foregroundColor(.hex_B86A6A)
                        } else {
                            if isDuplicated != nil {
                                if isDuplicated == true{
                                    Text("중복된 닉네임입니다")
                                        .font(.system(size: 13))
                                        .foregroundColor(.hex_B86A6A)
                                } else if isDuplicated == false {
                                    Text("사용할 수 있는 닉네임입니다")
                                        .font(.system(size: 13))
                                        .foregroundColor(.hex_627D41)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 14)
            }
            .padding(.top, -80)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button("저장") {
                        postNewMember()
                    }
                    .disabled(nickname.trimmingCharacters(in: .whitespaces) == "" || isDuplicated == nil || isDuplicated == true || textInputAccepted == false)
                })
            }
        }
    }
    
    func checkNicknameDuplication(nickname: String) {
        memberVM.checkNicknameDuplicationToServer(nicknameToCheck: nickname)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("중복검사 비동기 실패")
                    print("중복검사 Error: \(error.localizedDescription)")
                case .finished:
                    if let isDuplicated = memberVM.isDuplicated {
                        self.isDuplicated = isDuplicated
                    }
                }
            }, receiveValue: { isDuplicate in
                
            })
            .store(in: &memberVM.registerCancellables)
    }
    
    func postNewMember() {
        mocacongMemeberToRegister.nickname = self.nickname
        if mocacongMemeberToRegister.nickname != nil {
            memberVM.requestRegisterToServer(memberToRegister: mocacongMemeberToRegister)
                .sink(receiveCompletion: { result in
                    switch result {
                    case .failure(let error):
                        print("회원가입 error: \(error)")
                    case .finished:
                        break
                    }
                }, receiveValue: { data in
                })
                .store(in: &memberVM.registerCancellables)
        }
    }
}

struct RegistrationView_Preview: PreviewProvider {
    static var previews: some View {
        RegistrationView(memberVM: MemberViewModel(), mocacongMemeberToRegister: .constant(Member()))
    }
}
