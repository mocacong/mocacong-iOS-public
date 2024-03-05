//
//  CustomAnnotation.swift
//  mocacong
//
//  Created by Suji Lee on 2023/05/14.
//

import SwiftUI

struct CafeAnnotation: View {
    
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var cafeVM: CafeViewModel
    @ObservedObject var mapVM: MapViewModel
    @StateObject var previewVM: PreviewViewModel = PreviewViewModel()
    @ObservedObject var myVM: MyViewModel
    @Binding var currentMode: CurrentMode
    @State var targetPlace: CafePlace
    @State var cafeToPost: Cafe = Cafe()
    @State var showModal: Bool = false
    @Binding var profileImageData: Data?
    
    @State var showCafePage: Bool = false
    
    var body: some View {
            VStack(spacing: 0) {
                NavigationLink(destination: CafePageView(memberVM: memberVM, cafeVM: cafeVM, myVM: myVM), isActive: $showCafePage)
                {
                    Button(action: {
                        cafeToPost.name = targetPlace.placeName
                        cafeToPost.mapId = targetPlace.id
                        cafeToPost.phoneNumber = targetPlace.phone
                        cafeToPost.roadAddress = targetPlace.roadAddressName
                        
                        cafeVM.cafeData = cafeToPost
                        cafeVM.cafeMapId = targetPlace.id
                        
                        postCafe()
                        
                        if let token = TokenManager.shared.getToken() {
                            previewVM.fetchCafePreview(accessToken: token, mapId: targetPlace.id)
                        }
                    }, label: {
                        if targetPlace.favorite {
                            AnnotationMark(type: "FavoriteAnnotation")
                        } else if targetPlace.solo || targetPlace.group {
                            AnnotationMark(type: "MocafeAnnotation")
                        } else {
                            if targetPlace.id == "388741564" {
                                AnnotationMark(type: "MocafeAnnotation")
                            } else {
                                AnnotationMark(type: "CafeAnnotation")
                            }
                        }
                    })
                }
                Text(targetPlace.placeName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)
            }
        .sheet(isPresented: $showModal) {
            CafePreviewModal(memberVM: memberVM, cafeVM: cafeVM, previewVM: previewVM, showCafePage: $showCafePage)
                .presentationDetents([.large, .fraction(0.385)])
        }
        .onAppear {
            if currentMode == .search {
                print("타겟 장소 : ", targetPlace)
            }
        }
    }
    
    @ViewBuilder
    func AnnotationMark(type: String) -> some View {
            Image(type)
            .resizable()
            .scaledToFit()
            .frame(width: type == "MocafeAnnotation" ? 26 : 23, height: type == "MocafeAnnotation" ? 26 : 23)
    }
    
    func postCafe() {
        cafeVM.postNewCafe(cafeToPost: cafeToPost)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("카페 등록 비동기 error : \(error)")
                case .finished:
                    print("카페 등록 비동기 성공")
                    break
                }
            }, receiveValue: { data in
                showModal = true
            })
            .store(in: &mapVM.cancellables)
    }
}
