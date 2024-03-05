//
//  CafePageView.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/14.
//

import SwiftUI
import Combine

struct CafePageView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var memberVM : MemberViewModel
    @ObservedObject var cafeVM: CafeViewModel
    @ObservedObject var myVM: MyViewModel
    @StateObject var imageVM: ImageViewModel = ImageViewModel()
    @State var cafeCommentsData: CafeComments = CafeComments()
    
    var cafeMapIdFromMyPage: String? = nil
    
    @State var showEditModal: Bool = false
    @State var showCommentSheet: Bool = false
    @State var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                ZStack {
                    VStack {
                        ScrollView {
                            //리뷰 영역
                            CafeInfoView(memberVM: memberVM, cafeVM: cafeVM, imageVM: imageVM)
                            Divider()
                            //댓글 영역
                            VStack(spacing: 10) {
                                if let commentPreviewArray = cafeVM.cafeData.comments {
                                    VStack(alignment: .leading) {
                                        ForEach(commentPreviewArray, id: \.self) { comment in
//                                            NavigationLink(destination: {
//                                                CommentView(memberVM: memberVM, myVM: myVM, cafeVM: cafeVM)
//                                            }, label: {
//                                                CommentCard(myVM: myVM, comment: comment)
//                                            })
                                            CommentCard(myVM: myVM, comment: comment)
                                                .padding(.leading)
                                            Divider()
                                        }
                                    }
                                    if cafeVM.cafeData.commentsCount ?? 0 >= 1 {
                                        NavigationLink(destination: {
                                            CommentView(memberVM: memberVM, myVM: myVM, cafeVM: cafeVM)
                                        }, label: {
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: screenWidth * 0.95, height: 55)
                                                .foregroundColor(.clear)
                                                .overlay {
                                                    HStack {
                                                        Text("댓글 전체보기")
                                                            .font(.system(size: 16, weight: .medium))
                                                        Image(systemName: "arrow.right")
                                                        
                                                    }
                                                    .foregroundColor(Color.hex_5C4726)
                                                }
                                        })
                                    } else {
                                        VStack {
                                            Text("첫번째 댓글을 작성해주세요!")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color.hex_828282)
                                                .padding(.vertical, 20)
                                                .padding(.bottom, 10)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                CommentBlock(myVM: myVM)
                    .padding(.bottom, 3)
                    .onTapGesture {
                        showCommentSheet = true
                    }
            }
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17))
                    Text("Back")
                        .font(.system(size: 16))
                }
            })
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showCommentSheet) {
            CommentModal(memberVM: memberVM, cafeVM: cafeVM, myVM: myVM)
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            if let token = TokenManager.shared.getToken() {
                if let cafeMapIdFromMyPage = cafeMapIdFromMyPage {
                    cafeVM.cafeMapId = cafeMapIdFromMyPage
                    cafeVM.fetchCafeData(accessToken: token, mapId: cafeVM.cafeMapId)
                } else {
                    cafeVM.fetchCafeData(accessToken: token, mapId: cafeVM.cafeMapId)
                }
            }
        }
    }
}
