//
//  OnboardingView.swift
//  mocacong
//
//  Created by Suji Lee on 2023/08/03.
//
import SwiftUI

struct OnboardingView: View {
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @State private var currentIndex = 0
    
    var onboardingScreens: [String] = ["First", "Second", "Third", "Fourth", "Fifth"]
    
    var body: some View {
        if isFirstLaunch {
            ZStack {
                TabView(selection: $currentIndex) {
                    ForEach(onboardingScreens, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.8)
                            .tag(onboardingScreens.firstIndex(of: imageName)!)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                VStack {
                    HStack {
                        Button(action: previous) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                        }
                        .disabled(currentIndex == 0)
                        Spacer()
                        Button(action: {
                            next()
                        }, label: {
                            if currentIndex != 4 {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.black)
                                    .font(.system(size: 20))
                            } else {
                                Text("준비 완료!")
                                    .foregroundColor(.hex_627D41)
                                    .font(.system(size: 18, weight: .medium))
                            }
                        })
                    }
                    .padding()
                    .padding(.horizontal, 10)
                    Spacer()
                }
            }
            .background(Color.hex_EAEAE9)
        }
    }
    
    func next() {
        if currentIndex < 4 {
            currentIndex += 1
        } else if currentIndex == 4 {
            isFirstLaunch = false
        }
    }
    
    func previous() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
    
    func skip() {
        isFirstLaunch = false
    }
}
