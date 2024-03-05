//
//  ContentView.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/12.
//

import SwiftUI
import UIKit

var hasFetchedProfileData = false

var screenWidth = UIScreen.main.bounds.width
var screenHeight = UIScreen.main.bounds.height

let requestURL = Bundle.main.object(forInfoDictionaryKey: "ADMIN_URI") as? String ?? ""
//let requestURL = Bundle.main.object(forInfoDictionaryKey: "DEVELOPE_URI") as? String ?? ""

struct ContentView: View {
    
    @ObservedObject var stateManager = StateManager.shared
    @ObservedObject var tokenManager = TokenManager.shared
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    
    @ObservedObject var memberVM: MemberViewModel = MemberViewModel()
    @StateObject var cafeVM: CafeViewModel = CafeViewModel()
    @StateObject var myVM: MyViewModel = MyViewModel()
    @State var mocacongMember: Member = Member()
    @State var isRegistered: Bool = true
    @State var profileImageData: Data?
    @State var showLoginRequestAlert: Bool = false
    @State var showServerDownAlert: Bool = false
    
    //탭 바 커스텀을 위한 이니셜라이저
    init() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        VStack {
            if tokenManager.isAccessTokenPresent() == true && !stateManager.tokenExpired {
                if isRegistered == false && stateManager.isAgreed == false {
                    AgreementView()
                } else if isRegistered == false && stateManager.isAgreed == true {
                    RegistrationView(memberVM: memberVM, mocacongMemeberToRegister: $mocacongMember)
                } else if isRegistered == true && isFirstLaunch {
                    OnboardingView()
                } else if isRegistered == true {
                        MapView(memberVM: memberVM, cafeVM: cafeVM, myVM: myVM, profileImageData: $profileImageData)
                    .accentColor(Color.hex_4E483C)
                    .onAppear {
                        if let token = TokenManager.shared.getToken() {
                            myVM.fetchMyProfileData(accessToken: token)
                        }
                    }
                    .onReceive(myVM.$profileImageData) { newData in
                        self.profileImageData = newData
                    }
                }
            } else {
                LoginView(memberVM: memberVM)
            }
        }
        .onChange(of: stateManager.tokenExpired, perform: { newValue in
            if newValue == true {
                showLoginRequestAlert = true
            }
        })
        .onChange(of: stateManager.serverDown, perform: { newValue in
            if newValue == true {
                showServerDownAlert = true
            }
        })
        .alert("알림", isPresented: $showLoginRequestAlert, actions: {
            Button(action: {
                tokenManager.logoutUser()
            }, label: {
                Text("확인")
            })
        }, message: {
            Text("로그인이 필요한 서비스입니다")
        })
        .alert("알림", isPresented: $showServerDownAlert, actions: {
            Button(action: {
                tokenManager.logoutUser()
            }, label: {
                Text("확인")
            })
        }, message: {
                Text("일시적으로 접속이 원활하지 않습니다")
        })
        .onReceive(memberVM.$member) { member in
            mocacongMember = member
        }
        .onReceive(memberVM.$isRegistered) { isRegistered in
            if let isRegistered = isRegistered {
                self.isRegistered = isRegistered
            }
        }
    }
}

extension UIApplication {
    func hideKeyboard() {
        guard let window = windows.first else { return }
        let tapRecognizer = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self
        window.addGestureRecognizer(tapRecognizer)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

#Preview {
    ContentView()
}
