//
//  DetailInfoCard.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/25.
//

import SwiftUI

struct DetailInfoCard: View {
    
    var reviewType: String
    var titleReview: String
    
    var good = Color.hex_C1CFAF
    var soso = Color.hex_FFE7A9
    var bad = Color.hex_E7BDBD
    var none = Color.gray.opacity(0.15)
    var iconSize:CGFloat = 20
    
    var body: some View {
        HStack(spacing: 20) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 20, height: 20)
                .overlay(
                    reviewIcon()
                )
           if reviewType == "wifi" {
               ReviewFrame(text: titleReview)
                   .foregroundColor(titleReview == "빵빵해요" ? good : (titleReview == "적당해요" ? soso : (titleReview == "리뷰가 없어요" ? none : bad)))
            } else if reviewType == "toilet" {
                ReviewFrame(text: titleReview)
                    .foregroundColor(titleReview == "깨끗해요" ? good : (titleReview == "평범해요" ? soso : (titleReview == "리뷰가 없어요" ? none : bad)))
            } else if reviewType == "parking" {
                ReviewFrame(text: titleReview)
                    .foregroundColor(titleReview == "여유로워요" ? good : (titleReview == "협소해요" ? soso : (titleReview == "리뷰가 없어요" ? none : bad)))
            } else if reviewType == "power" {
                ReviewFrame(text: titleReview)
                    .foregroundColor(titleReview == "충분해요" ? good : (titleReview == "적당해요" ? soso : (titleReview == "리뷰가 없어요" ? none : bad)))
            } else if reviewType == "sound" {
                ReviewFrame(text: titleReview)
                    .foregroundColor(titleReview == "조용해요" ? good : (titleReview == "적당해요" ? soso : (titleReview == "리뷰가 없어요" ? none : bad)))
           } else if reviewType == "desk" {
               ReviewFrame(text: titleReview)
                   .foregroundColor(titleReview == "편해요" ? good : (titleReview == "보통이에요" ? soso : (titleReview == "리뷰가 없어요" ? none : bad)))
           }
        }
    }
    
    @ViewBuilder
    func ReviewFrame(text: String) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 112, height: 28)
            .overlay(
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.hex_4E483C)
            )
    }
    
    @ViewBuilder
    func reviewIcon() -> some View {
        VStack {
            if reviewType == "wifi" {
                Image("wifi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize)
            } else if reviewType == "toilet" {
                Image("toilet")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize)
            } else if reviewType == "parking" {
                Image("parking")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize)
            } else if reviewType == "power" {
                Image("power")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize)
            } else if reviewType == "sound" {
                Image("sound")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize)
            } else if reviewType == "desk" {
                Image("desk")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize)
            }
        }
    }
}
