//
//  AgreementView.swift
//  ecopercent
//
//  Created by Suji Lee on 2023/07/05.
//

import SwiftUI

struct AgreementView: View {
    
    @ObservedObject var stateManager = StateManager.shared
    @ObservedObject var tokenManager = TokenManager.shared
    
    var allChecked: Bool {
        if self.utilizationContractChecked && self.personalInfoContractChecked && self.ageChecked && self.locationServiceContractChecked {
            return true
        } else {
            return false
        }
    }
    @State var ageChecked: Bool = false
    @State var utilizationContractChecked: Bool = false
    @State var personalInfoContractChecked: Bool = false
    @State var locationServiceContractChecked: Bool = false
    var fontSize: CGFloat = 14
    
    var body: some View {
        NavigationView {
            VStack {
                //헤더
                VStack(alignment: .leading, spacing: 4) {
                    Text("모카콩")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.hex_625D57)
                    VStack(alignment: .leading) {
                        Text("서비스 이용을 위해")
                        Text("아래 항목에 동의해주세요")
                        
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.hex_4E483C)
                }
                .padding(.leading, -155)
                .padding(.bottom, 60)
                //동의 영역
                VStack(spacing: 12) {
                    //모두 동의
                    HStack {
                        Spacer()
                        Text("모두 동의")
                            .font(.system(size: fontSize, weight: .medium))
                            .foregroundColor(.hex_8C9F75)
                            .padding(.leading)
                        Button(action: {
                                if allChecked == true {
                                    ageChecked = false
                                    utilizationContractChecked = false
                                    personalInfoContractChecked = false
                                    locationServiceContractChecked = false
                                } else {
                                    ageChecked = true
                                    utilizationContractChecked = true
                                    personalInfoContractChecked = true
                                    locationServiceContractChecked = true
                                }
                        }, label: {
                            CheckBox(checked: allChecked)
                        })
                    }
                    //구분선
                    Divider()
                        .frame(width: screenWidth * 0.87)
                    //세부 동의
                    VStack(alignment: .leading, spacing: 19) {
                        //이용약관
                        HStack {
                            Text("만 14세 이상입니다")
                                .font(.system(size: fontSize))
                                .foregroundColor(.hex_4F4A44)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    ageChecked.toggle()
                                }
                            }, label: {
                                CheckBox(checked: ageChecked)
                            })
                        }
                        HStack {
                            Text("이용약관 동의")
                                .font(.system(size: fontSize))
                                .foregroundColor(.hex_4F4A44)
                            Spacer()
                            Button(action: {
                                if let url = URL(string: "https://www.notion.so/mocacong/78a169a2532a4e9e94fe2ae2da41c6a4") {
                                    UIApplication.shared.open(url)
                                }
                            }, label: {
                                Text("내용보기")
                                    .foregroundColor(.hex_7E7E7E)
                                    .font(.system(size: 14))
                            })
                            Button(action: {
                                withAnimation {
                                    utilizationContractChecked.toggle()
                                }
                            }, label: {
                                CheckBox(checked: utilizationContractChecked)
                            })
                        }
                        //위치기반서비스이용약관
                        HStack {
                            Text("위치기반 서비스 이용 약관 동의")
                                .font(.system(size: fontSize))
                                .foregroundColor(.hex_4F4A44)
                            Spacer()
                                Button(action: {
                                if let url = URL(string: "https://www.notion.so/mocacong/36de943075a2454d9bc3383e909c1390") {
                                    UIApplication.shared.open(url)
                                }
                            }, label: {
                                Text("내용보기")
                                    .foregroundColor(.hex_7E7E7E)
                                    .font(.system(size: 14))
                            })
                            Button(action: {
                                withAnimation {
                                    locationServiceContractChecked.toggle()
                                }
                            }, label: {
                                CheckBox(checked: locationServiceContractChecked)
                            })
                        }
                        //개인정보 수집 및 이용 동의
                        HStack {
                            Text("개인정보 수집 및 이용 동의")
                                .font(.system(size: fontSize))
                                .foregroundColor(.hex_4F4A44)
                            Spacer()
                            Button(action: {
                                if let url = URL(string: "https://www.notion.so/mocacong/053df0bda1674234a5252d8bc82a4b7b") {
                                    UIApplication.shared.open(url)
                                }
                            }, label: {
                                Text("내용보기")
                                    .foregroundColor(.hex_7E7E7E)
                                .font(.system(size: 14))                        })
                            Button(action: {
                                withAnimation {
                                    personalInfoContractChecked.toggle()
                                }
                            }, label: {
                                CheckBox(checked: personalInfoContractChecked)
                            })
                        }
                    }
                }
                .padding(.bottom, 40)
                //가입하기 버튼
                Button(action: {
                    stateManager.isAgreed = true
                }, label: {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(allChecked == true ? .hex_8C9F75 : .hex_A49E99)
                        .frame(width: screenWidth * 0.9, height: 50)
                        .overlay (
                            Text("가입하기")
                                .foregroundColor(.white)
                                .font(.system(size: 17))
                        )
                })
                .disabled(allChecked == false)
                .padding()
            }
            .padding(.top, 30)
            .padding(.bottom, 85)
            .frame(width: screenWidth * 0.87)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button(action: {
                        stateManager.isAgreed = false
                        tokenManager.logoutUser()
                    }, label: {
                        HStack(spacing: 2) {
                            Image(systemName: "chevron.left")
                            Text("취소")
                                .font(.system(size: 17, weight: .semibold))
                        }
                    })
                })
            }
        }
    }
    
    @ViewBuilder
    func CheckBox(checked: Bool) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .stroke(Color.hex_7E7E7E, lineWidth: 0.5)
            .frame(width: 25, height: 25)
            .overlay {
                Image(systemName: checked == true ? "checkmark" : "")
                    .foregroundColor(.hex_B86A6A)
                    .font(.system(size: 15, weight: .semibold))
            }
            .padding(.horizontal, 5)
    }
}

#Preview {
    AgreementView(ageChecked: true, utilizationContractChecked: true, personalInfoContractChecked: true, locationServiceContractChecked: true, fontSize: 14.5)
}
