//
//  CommentCard.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/28.
//

import SwiftUI
import SDWebImageSwiftUI

struct CommentCard: View {
    
    @ObservedObject var myVM: MyViewModel
    var comment: Comment
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 12.5) {
                //프로필
                VStack(spacing: 3) {
                    //프로필 이미지
                    VStack {
                        if comment.isMe ?? false == true {
                            if let imageData = myVM.profileImageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle()
                                            .stroke(Color.hex_828282, lineWidth: 0.3)
                                    }
                                    .overlay(
                                        Text(comment.isMe ?? false ? "my" : "")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundColor(.white)
                                            .frame(width: 24, height: 13.5)
                                            .background(Color.hex_5C4726, in: RoundedRectangle(cornerRadius: 5))
                                            .offset(x: -13, y: -17)
                                    )
                            } else {
                                Image("noProfile")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .overlay {
                                        Text(comment.isMe ?? false ? "My" : "")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundColor(.white)
                                            .frame(width: 24, height: 13.5)
                                            .background(Color.hex_5C4726, in: RoundedRectangle(cornerRadius: 5))
                                            .offset(x: -13, y: -17)
                                    }
                            }
                        } else if comment.isMe ?? false == false {
                            if let imageUrl = comment.imgUrl {
                                WebImage(url: URL(string: imageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Image("noProfile")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    //닉네임
                    Text(comment.nickname ?? "콩콩이")
                        .font(.system(size: 11.4, weight: .semibold))
                        .foregroundColor(.hex_4E483C)
                }
                .frame(width: 60)
                .offset(y: 4)
                //내용
                VStack(alignment: .leading) {
                    Text(comment.content ?? "내용없음")
                        .font(.system(size: 14.7))
                        .foregroundColor(.hex_483F30)
                }
                .padding(.trailing, 10)
            }
        }
        .padding(.vertical, 5)
    }
}

#Preview {
    VStack {
        CommentCard(myVM: MyViewModel(), comment: Comment(content: "sdfsdf"))
        CommentCard(myVM: MyViewModel(), comment: Comment(content: "sdfsdf"))
    }
}
