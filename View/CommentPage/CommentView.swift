//
//  CafeCommentView.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/28.
//

import SwiftUI

struct CommentView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var myVM: MyViewModel
    @ObservedObject var cafeVM: CafeViewModel
    @StateObject var commentVM: CommentViewModel = CommentViewModel()
    
    @State var targetComment: Comment = Comment()
    //뷰 제어
    @State var showCommentModalOnCommentView: Bool = false
    @State var showCommentEditSheet: Bool = false
    @State var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                //헤더
                VStack(spacing: 10) {
                    VStack {
                        Text(cafeVM.cafeData.name ?? "상호 불명")
                            .foregroundStyle(Color.hex_483F30)
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 5.5)
                            .padding(.bottom, 4.5)
                            .overlay(alignment: .bottom, content: {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.hex_4F4A44)
                                    .frame(height: 1.3)
                            })
                        Text(cafeVM.cafeData.roadAddress ?? "주소 불명")
                            .font(.system(size: 17))
                            .foregroundColor(.hex_5C4726)
                            .padding(.bottom, 10)
                    }
                    .offset(y: 3)
                    //댓글 개수
                    HStack {
                        Spacer()
                        if let commentCount = cafeVM.cafeData.commentsCount {
                            Text("댓글 "
                                 + commentCount.description +
                                 "개")
                            .foregroundColor(.hex_4E483C)
                            .font(.system(size: 14))
                        }
                    }
                    .padding(.trailing, 18)
                    .offset(y: 8)
                }
                .frame(width: screenWidth)
                .padding(.vertical, 20)
                .padding(.bottom, 2)
                .background(Color.hex_C2B8AF.opacity(0.2))
                //댓글 리스트
                List {
                    ForEach(commentVM.disPlayCommentArray, id: \.self) { comment in
                        if comment.isMe ?? false {
                            CommentCard(myVM: myVM, comment: comment)
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        targetComment = comment
                                        showCommentEditSheet = true
                                    } label: {
                                        Label("", systemImage: "pencil")
                                    }
                                    .tint(.hex_627D41)
                                    Button {
                                        targetComment = comment
                                        showAlert = true
                                    } label: {
                                        Label("", systemImage: "trash")
                                    }
                                    .tint(.hex_B86A6A)
                                }
                        } else {
                            CommentCard(myVM: myVM, comment: comment)
                        }
                    }
                    //더보기
                    if let isEnd = commentVM.cafeCommentsData.isEnd, isEnd == false {
                        Button(action: {
                            loadMoreComments()
                        }, label: {
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: screenWidth * 0.95, height: 55)
                                .foregroundColor(Color.hex_C2B8AF.opacity(0.2))
                                .overlay {
                                    Text("더보기")
                                        .font(.system(size: 15.5, weight: .semibold))
                                        .foregroundColor(.hex_625D57)
                                }
                                .padding(.leading, 3)
                        })
                    }
                }
                .listStyle(PlainListStyle())

                CommentBlock(myVM: myVM)
                    .padding(.bottom, 3)
                    .onTapGesture {
                        showCommentModalOnCommentView = true
                    }
            }
        }
        .onAppear {
            if let token = TokenManager.shared.getToken() {
                commentVM.fetchCommentData(accessToken: token, mapId: cafeVM.cafeMapId, page: 0)
            }
        }
        .onDisappear {
            if let token = TokenManager.shared.getToken() {
                cafeVM.fetchCafeData(accessToken: token, mapId: cafeVM.cafeMapId)
            }
        }
        .sheet(isPresented: $showCommentModalOnCommentView) {
            CommentModal(memberVM: memberVM, cafeVM: cafeVM, myVM: myVM, commentVM: commentVM)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showCommentEditSheet) {
            CommentEditModal(memberVM: memberVM, cafeVM: cafeVM, myVM: myVM, commentVM: commentVM, targetComment: $targetComment)
                .presentationDragIndicator(.visible)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("댓글 삭제"),
                message: Text("댓글을 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("취소")),
                secondaryButton: .cancel(Text("삭제"),action: {
                    deleteComment()
                }))
        }
    }
    
    func loadMoreComments() {
        if let token = TokenManager.shared.getToken(), let isEnd = commentVM.cafeCommentsData.isEnd, isEnd == false {
            commentVM.loadMoreComments(accessToken: token, cafeVM: cafeVM)
        }
    }
    
    func deleteComment() {
        if let token = TokenManager.shared.getToken() {
            commentVM.deleteComment(accessToken: token, mapId: cafeVM.cafeMapId, commentToEdit: targetComment)
        }
    }
}
