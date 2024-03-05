//
//  CafeEditModal.swift
//  mocacong
//
//  Created by Suji Lee on 2023/05/04.
//

import SwiftUI
import Combine

struct CafeReviewModal: View {
        
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var cafeVM: CafeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State var myReviewToPost: Review = Review()
    @State var myReviewToEdit: Review = Review()
    
    var good = Color.good.opacity(0.5)
    var soso = Color.soso.opacity(0.5)
    var bad = Color.bad.opacity(0.5)
    
    @State var selectedScore: Int?
    @State var soloTypeSelected: Bool = false
    @State var groupTypeSelected: Bool = false
    @State var selectedStudyType: String?
    @State var selectedWifi: String?
    @State var selectedDesk: String?
    @State var selectedPower: String?
    @State var selectedSound: String?
    @State var selectedToilet: String?
    @State var selectedParking: String?
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                //카페 상호 및 도로명 주소
                VStack(spacing: 3.5) {
                    Text(cafeVM.cafeData.name ?? "")
                        .font(.system(size: 20, weight: .bold))
                    Text(cafeVM.cafeData.roadAddress ?? "")
                        .font(.system(size: 14))
                }
                .foregroundColor(.hex_4E483C)
                //평점 및 스터디타입
                VStack(spacing: 5) {
                    //평점
                    Image(systemName: "staroflife.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.hex_B86A6A)
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Button(action: {
                                withAnimation(.easeInOut(duration: -1)) {
                                    selectedScore = index + 1
                                }
                            }, label: {
                                Image(index < selectedScore ?? 0 ? "Mocacong" : "MocacongNil")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 43)
                            })
                        }
                    }
                    //스터디타입
                    VStack(spacing: 5) {
                        HStack {
                            Button(action: {
                                soloTypeSelected.toggle()
                            }, label: {
                                RoundedRectangle(cornerRadius: 30)
                                    .frame(width: 80, height: 35)
                                    .foregroundColor(soloTypeSelected == false ? .hex_958B7C.opacity(0.2) : .hex_5C5041.opacity(0.5))
                                    .overlay(
                                        Text("혼자")
                                            .font(.system(size: 17, weight: .medium))
                                            .foregroundStyle(Color.hex_4F4A44)
                                    )
                            })
                            Button(action: {
                                groupTypeSelected.toggle()
                            }, label: {
                                RoundedRectangle(cornerRadius: 30)
                                    .frame(width: 80, height: 35)
                                    .foregroundColor(groupTypeSelected == false ? .hex_958B7C.opacity(0.2) : .hex_5C5041.opacity(0.5))
                                    .overlay(
                                        Text("같이")
                                            .font(.system(size: 17, weight: .medium))
                                            .foregroundStyle(Color.hex_4F4A44)
                                    )
                            })
                        }
                    }
                }
                .frame(width: screenWidth, height: screenWidth * 0.4)
                .padding(.top, -10)
                //디테일 리뷰
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {

                        //데스크
                        VStack {
                            Label(name: "테이블")
                                .overlay(
                                    Image(systemName: "staroflife.fill")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.hex_B86A6A)
                                        .offset(y: -25)
                                )
                            HStack(spacing: 30) {
                                let badDesk = Desk(imageName: "bad"), sosoDesk = Desk(imageName: "soso"), goodDesk = Desk(imageName: "good")
                                Button(action: {
                                    if selectedDesk == nil {
                                        selectedDesk = "편해요"
                                    } else if selectedDesk == "편해요" {
                                        selectedDesk = nil
                                    } else {
                                        selectedDesk = "편해요"
                                    }
                                }, label: {
                                    VStack {
                                        goodDesk.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedDesk == "편해요" ? good : .clear)
                                            )
                                        Text("편해요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                                Button(action: {
                                    if selectedDesk == nil {
                                        selectedDesk = "보통이에요"
                                    } else if selectedDesk == "보통이에요" {
                                        selectedDesk = nil
                                    } else {
                                        selectedDesk = "보통이에요"
                                    }
                                }, label: {
                                    VStack {
                                        sosoDesk.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedDesk == "보통이에요" ? soso : .clear)
                                            )
                                        Text("보통이에요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                                .padding(.trailing, -9)
                                Button(action: {
                                    if selectedDesk == nil {
                                        selectedDesk = "불편해요"
                                    } else if selectedDesk == "불편해요" {
                                        selectedDesk = nil
                                    } else {
                                        selectedDesk = "불편해요"
                                    }
                                }, label: {
                                    VStack {
                                        badDesk.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedDesk == "불편해요" ? bad : .clear)
                                            )
                                        Text("불편해요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                            }
                            .frame(width: 280)
                        }
                        .padding(.top, 25)

                        //콘센트
                        VStack {
                            Label(name: "콘센트")
                                .overlay(
                                    Image(systemName: "staroflife.fill")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.hex_B86A6A)
                                        .offset(y: -25)
                                )
                            HStack(spacing: 30) {
                                let badWifi = Wifi(imageName: "bad"), sosoWifi = Wifi(imageName: "soso"), goodWifi = Wifi(imageName: "good")
                                Button(action: {
                                    if selectedPower == nil {
                                        selectedPower = "충분해요"
                                    } else if selectedPower == "충분해요" {
                                        selectedPower = nil
                                    } else {
                                        selectedPower = "충분해요"
                                    }
                                }, label: {
                                    VStack {
                                        goodWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedPower == "충분해요" ? good : .clear)
                                            )
                                        Text("충분해요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                                Button(action: {
                                    if selectedPower == nil {
                                        selectedPower = "적당해요"
                                    } else if selectedPower == "적당해요" {
                                        selectedPower = nil
                                    } else {
                                        selectedPower = "적당해요"
                                    }
                                }, label: {
                                    VStack {
                                        sosoWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedPower == "적당해요" ? soso : .clear)
                                            )
                                        Text("적당해요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                                Button(action: {
                                    if selectedPower == nil {
                                        selectedPower = "없어요"
                                    } else if selectedPower == "없어요" {
                                        selectedPower = nil
                                    } else {
                                        selectedPower = "없어요"
                                    }
                                }, label: {
                                    VStack {
                                        badWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedPower == "없어요" ? bad : .clear)
                                            )
                                        Text("없어요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                            }
                            .frame(width: 280)
                        }
                        
                        //와이파이
                        VStack(spacing: 12) {
                            Label(name: "와이파이")
                            HStack(spacing: 30) {
                                let badWifi = Wifi(imageName: "bad"), sosoWifi = Wifi(imageName: "soso"), goodWifi = Wifi(imageName: "good")
                                Button(action: {
                                    if selectedWifi == nil {
                                        selectedWifi = "빵빵해요"
                                    } else if selectedWifi == "빵빵해요" {
                                        selectedWifi = nil
                                    } else {
                                        selectedWifi = "빵빵해요"
                                    }
                                }, label: {
                                    VStack {
                                        goodWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedWifi == "빵빵해요" ? good : .clear)
                                            )
                                        Text("빵빵해요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                                Button(action: {
                                    if selectedWifi == nil {
                                        selectedWifi = "적당해요"
                                    } else if selectedWifi == "적당해요" {
                                        selectedWifi = nil
                                    } else {
                                        selectedWifi = "적당해요"
                                    }
                                }, label: {
                                    VStack {
                                        sosoWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedWifi == "적당해요" ? soso : .clear)
                                            )
                                        Text("적당해요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                                Button(action: {
                                    if selectedWifi == nil {
                                        selectedWifi = "느려요"
                                    } else if selectedWifi == "느려요" {
                                        selectedWifi = nil
                                    } else {
                                        selectedWifi = "느려요"
                                    }
                                }, label: {
                                    //
                                    VStack {
                                        badWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedWifi == "느려요" ? bad : .clear)
                                            )
                                        Text("느려요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                            }
                            .frame(width: 280)
                        }
                        
                        //분위기
                        VStack {
                            Label(name: "분위기")
                            HStack(spacing: 30) {
                                let badWifi = Wifi(imageName: "bad"), sosoWifi = Wifi(imageName: "soso"), goodWifi = Wifi(imageName: "good")
                                Button(action: {
                                    if selectedSound == nil {
                                        selectedSound = "조용해요"
                                    } else if selectedSound == "조용해요" {
                                        selectedSound = nil
                                    } else {
                                        selectedSound = "조용해요"
                                    }
                                }, label: {
                                    VStack {
                                        goodWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedSound == "조용해요" ? good : .clear)
                                            )
                                        Text("조용해요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                                Button(action: {
                                    if selectedSound == nil {
                                        selectedSound = "적당해요"
                                    } else if selectedSound == "적당해요" {
                                        selectedSound = nil
                                    } else {
                                        selectedSound = "적당해요"
                                    }
                                }, label: {
                                    VStack {
                                        sosoWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedSound == "적당해요" ? soso : .clear)
                                            )
                                        Text("적당해요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                                Button(action: {
                                    if selectedSound == nil {
                                        selectedSound = "북적북적해요"
                                    } else if selectedSound == "북적북적해요" {
                                        selectedSound = nil
                                    } else {
                                        selectedSound = "북적북적해요"
                                    }
                                }, label: {
                                    VStack {
                                        badWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedSound == "북적북적해요" ? bad : .clear)
                                            )
                                        Text("북적해요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                            }
                            .frame(width: 280)
                        }
                        
                        //화장실
                        VStack {
                            Label(name: "화장실")
                            HStack(spacing: 30) {
                                let badWifi = Wifi(imageName: "bad"), sosoWifi = Wifi(imageName: "soso"), goodWifi = Wifi(imageName: "good")
                                Button(action: {
                                    if selectedToilet == nil {
                                        selectedToilet = "깨끗해요"
                                    } else if selectedToilet == "깨끗해요" {
                                        selectedToilet = nil
                                    } else {
                                        selectedToilet = "깨끗해요"
                                    }
                                }, label: {
                                    VStack {
                                        goodWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedToilet == "깨끗해요" ? good : .clear)
                                            )
                                        Text("깨끗해요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                                Button(action: {
                                    if selectedToilet == nil {
                                        selectedToilet = "평범해요"
                                    } else if selectedToilet == "평범해요" {
                                        selectedToilet = nil
                                    } else {
                                        selectedToilet = "평범해요"
                                    }
                                }, label: {
                                    VStack {
                                        sosoWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedToilet == "평범해요" ? soso : .clear)
                                            )
                                        Text("평범해요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                                Button(action: {
                                    if selectedToilet == nil {
                                        selectedToilet = "불편해요"
                                    } else if selectedToilet == "불편해요" {
                                        selectedToilet = nil
                                    } else {
                                        selectedToilet = "불편해요"
                                    }
                                }, label: {
                                    VStack {
                                        badWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedToilet == "불편해요" ? bad : .clear)
                                            )
                                        Text("불편해요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                            }
                            .frame(width: 280)
                        }
                        
                        //주차장
                        VStack {
                            Label(name: "주차장")
                            HStack(spacing: 30) {
                                var badWifi = Wifi(imageName: "bad"), sosoWifi = Wifi(imageName: "soso"), goodWifi = Wifi(imageName: "good")
                                Button(action: {
                                    if selectedParking == nil {
                                        selectedParking = "여유로워요"
                                    } else if selectedParking == "여유로워요" {
                                        selectedParking = nil
                                    } else {
                                        selectedParking = "여유로워요"
                                    }
                                }, label: {
                                    VStack {
                                        goodWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedParking == "여유로워요" ? good : .clear)
                                            )
                                        Text("충분해요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                                Button(action: {
                                    if selectedParking == nil {
                                        selectedParking = "협소해요"
                                    } else if selectedParking == "협소해요" {
                                        selectedParking = nil
                                    } else {
                                        selectedParking = "협소해요"
                                    }
                                }, label: {
                                    VStack {
                                        sosoWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedParking == "협소해요" ? soso : .clear)
                                            )
                                        Text("협소해요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                                Button(action: {
                                    if selectedParking == nil {
                                        selectedParking = "없어요"
                                    } else if selectedParking == "없어요" {
                                        selectedParking = nil
                                    } else {
                                        selectedParking = "없어요"
                                    }
                                }, label: {
                                    VStack {
                                        badWifi.image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40)
                                            .overlay(
                                                Circle()
                                                    .foregroundColor(selectedParking == "없어요" ? bad : .clear)
                                            )
                                        Text("없어요")
                                            .foregroundColor(.hex_4E483C)
                                            .font(.system(size: 13, weight: .semibold))
                                    }
                                })
                            }
                            .frame(width: 280)
                            .padding(.bottom, 25)
                        }
                    }
                    .frame(width: screenWidth * 0.9)
                    .padding(.top)
                    .background(Color.hex_958B7C.opacity(0.2), in: RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(.top, 25)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("취소")
                            .foregroundStyle(Color.hex_4F4A44)
                    })
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(action: {
                        if selectedStudyType == nil {
                            postReview()
                        } else {
                            editReview()
                        }
                        showAlert = true
                    }, label: {
                        if selectedScore == nil || selectedDesk == nil || selectedPower == nil || (soloTypeSelected == false && groupTypeSelected == false) {
                            Text("저장")
                                .fontWeight(.thin)
                                .foregroundStyle(Color.gray.opacity(0.7))
                        } else {
                            Text("저장")
                                .foregroundStyle(Color.hex_627D41)
                                .fontWeight(.semibold)
                        }
                    })
                    .disabled(selectedScore == nil || selectedDesk == nil || selectedPower == nil || (soloTypeSelected == false && groupTypeSelected == false))
                })
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("알림"),
                message: Text("리뷰가 저장되었습니다"),
                dismissButton: .default(Text("확인")) {
                    showAlert = false
                    dismiss()
                }
            )
        }
        .onAppear {
            selectedScore = cafeVM.myCafeReviewData.myScore
            selectedStudyType = cafeVM.myCafeReviewData.myStudyType
            selectedDesk = cafeVM.myCafeReviewData.myDesk
            selectedWifi = cafeVM.myCafeReviewData.myWifi
            selectedPower = cafeVM.myCafeReviewData.myPower
            selectedSound = cafeVM.myCafeReviewData.mySound
            selectedToilet = cafeVM.myCafeReviewData.myToilet
            selectedParking = cafeVM.myCafeReviewData.myParking
            if let studyType = selectedStudyType {
                if studyType == "solo" {
                    self.soloTypeSelected = true
                    self.groupTypeSelected = false
                } else if studyType == "group" {
                    self.groupTypeSelected = true
                    self.soloTypeSelected = false
                } else {
                    self.soloTypeSelected = true
                    self.groupTypeSelected = true
                }
            }
        }
        .onDisappear {
            if let token = TokenManager.shared.getToken() {
                cafeVM.fetchCafeData(accessToken: token, mapId: cafeVM.cafeMapId)
            }
        }
    }

    @ViewBuilder
    func Label(name: String) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundColor(.hex_B0A091.opacity(0.35))
            .frame(width: 80, height: 30)
            .overlay(
                Text(name)
                    .foregroundColor(.hex_4E483C)
                    .font(.system(size: 14, weight: .semibold))
            )
    }
    
    func postReview() {
        myReviewToPost.myScore = self.selectedScore
        if soloTypeSelected == true && groupTypeSelected == false {
            myReviewToPost.myStudyType = "solo"
        } else if soloTypeSelected == false && groupTypeSelected == true {
            myReviewToPost.myStudyType = "group"
        } else if soloTypeSelected == true && groupTypeSelected == true {
            myReviewToPost.myStudyType = "both"
        } else {
            print("all nil")
        }
        myReviewToPost.myWifi = self.selectedWifi
        myReviewToPost.myDesk = self.selectedDesk
        myReviewToPost.myParking = self.selectedParking
        myReviewToPost.myPower = self.selectedPower
        myReviewToPost.myToilet = self.selectedToilet
        myReviewToPost.mySound = self.selectedSound
        if let token = TokenManager.shared.getToken() {
            if myReviewToPost.myScore != nil && myReviewToPost.myStudyType != nil {
                cafeVM.postMyCafeReview(accesToken: token, mapId: cafeVM.cafeMapId, reviewToPost: myReviewToPost)
            }
        }
    }
    
    func editReview() {
        myReviewToEdit.myScore = self.selectedScore
        if soloTypeSelected == true && groupTypeSelected == false {
            myReviewToEdit.myStudyType = "solo"
        } else if soloTypeSelected == false && groupTypeSelected == true {
            myReviewToEdit.myStudyType = "group"
        } else if soloTypeSelected == true && groupTypeSelected == true {
            myReviewToEdit.myStudyType = "both"
        } else {
            print("all nil")
        }
        myReviewToEdit.myWifi = self.selectedWifi
        myReviewToEdit.myDesk = self.selectedDesk
        myReviewToEdit.myParking = self.selectedParking
        myReviewToEdit.myPower = self.selectedPower
        myReviewToEdit.myToilet = self.selectedToilet
        myReviewToEdit.mySound = self.selectedSound
        if let token = TokenManager.shared.getToken() {
            if myReviewToEdit.myScore != nil && myReviewToEdit.myStudyType != nil {
                cafeVM.updateMyCafeReview(accesToken: token, mapId: cafeVM.cafeMapId, reviewToEdit: myReviewToEdit)
            }
        }
    }
    
}
