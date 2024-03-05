//
//  CommentModal.swift
//  mocacong
//
//  Created by Suji Lee on 2023/04/24.
//

import SwiftUI

struct CommentEditModal: View {
    
    enum FocusTextEditor: Hashable {
       case textEditor
     }
    @FocusState private var focusTextEditor: FocusTextEditor?
    
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var cafeVM: CafeViewModel
    @ObservedObject var myVM: MyViewModel
    @ObservedObject var commentVM: CommentViewModel
    @Environment(\.dismiss) private var dismiss
    @State var content: String = ""
    @Binding var targetComment: Comment
    var isAvailableToSend: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    //헤더
                    VStack(spacing: 10) {
                        Text(cafeVM.cafeData.name ?? "상호 불명")
                            .foregroundStyle(Color.hex_483F30)
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 5.5)
                            .padding(.bottom, 4.5)
                            .overlay(alignment: .bottom, content: {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.hex_4F4A44)
                                    .frame(height: 1)
                            })
                        Text(cafeVM.cafeData.roadAddress ?? "주소 불명")
                            .font(.system(size: 16))
                            .foregroundColor(.hex_4F4A44)
                    }
                    .frame(width: screenWidth)
                    .offset(y: -25)
                    .padding(.bottom, 10)
                    VStack {
                        //프로필
                        HStack {
                            MyProfileInCommentModal(myVM: myVM)
                            Spacer()
                        }
                        .padding(.bottom)
                        .padding(.leading, 7)
                        //글자수
                        HStack {
                            if content.count == 0 {
                                Text("1~200자로 입력해주세요")
                                    .font(.system(size: 13))
                                    .foregroundColor(.hex_BABABA)
                            }
                            Spacer()
                            Text("\(content.count)/200")
                                .font(.system(size: 14))
                                .foregroundColor(content.count > 200 ? .red : .hex_7E7E7E)
                        }
                        //입력창
                        VStack {
                            TextEditor(text: $content)
                                .focused($focusTextEditor, equals: .textEditor)
                                .frame(width: screenWidth * 0.84, height: 230)
                                .padding(5)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.hex_BABABA, lineWidth: 0.5)
                                }
                        }
                        //경고 메세지
                        HStack {
                            Spacer()
                            Text(content.trimmingCharacters(in: .whitespaces) == "" ? "공백만으로 이루어질 수 없습니다" : "")
                            Text(content.count > 200 ? "200자를 초과할 수 없습니다" : "")
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.hex_B86A6A)
                    }
                    .frame(width: screenWidth * 0.85)
                }
                .padding(.top, 75)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("취소")
                            .foregroundColor(.hex_958B7C)
                    })
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(action: {
                        editComment()
                        dismiss()
                    }, label: {
                        Text("전송")
                            .foregroundColor (
                                (content.trimmingCharacters(in: .whitespaces) == "" || content.count > 200) ? .hex_7E7E7E : .hex_627D41)
                    })
                    .disabled(content.trimmingCharacters(in: .whitespaces) == "" || content.count > 200)
                })
            }
        }
        .onAppear {
            self.focusTextEditor = .textEditor
            self.content = targetComment.content ?? ""
        }
    }
    
    func editComment() {
        targetComment.content = self.content
        if let token = TokenManager.shared.getToken() {
            commentVM.updateComment(accessToken: token, mapId: cafeVM.cafeMapId, commentToEdit: targetComment)
        }
    }
}
