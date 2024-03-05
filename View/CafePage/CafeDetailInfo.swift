//
//  CafeDetailInfoView.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/25.
//

import SwiftUI

struct CafeDetailInfo: View {
    
    @ObservedObject var cafeVM: CafeViewModel
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 30) {
                HStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 20) {
                        DetailInfoCard(reviewType: "power", titleReview: cafeVM.cafeData.power ?? "리뷰가 없어요")
                        DetailInfoCard(reviewType: "wifi", titleReview: cafeVM.cafeData.wifi ?? "리뷰가 없어요")
                        DetailInfoCard(reviewType: "toilet", titleReview: cafeVM.cafeData.toilet ?? "리뷰가 없어요")
                    }
                    VStack(alignment: .leading, spacing: 20) {
                        DetailInfoCard(reviewType: "desk", titleReview: cafeVM.cafeData.desk ?? "리뷰가 없어요")
                        DetailInfoCard(reviewType: "sound", titleReview: cafeVM.cafeData.sound ?? "리뷰가 없어요")
                        DetailInfoCard(reviewType: "parking", titleReview: cafeVM.cafeData.parking ?? "리뷰가 없어요")
                    }
                }
            }
            .padding(.top, -7)
        }
    }
}
