//
//  CafeContentView.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/28.
//

import SwiftUI

struct CafeInfoView: View {
    
    @ObservedObject var memberVM: MemberViewModel
    @ObservedObject var cafeVM: CafeViewModel
    @ObservedObject var imageVM: ImageViewModel

    var body: some View {
        VStack {
            CafeHeader(memberVM: memberVM, cafeVM: cafeVM, imageVM: imageVM)
            CafeBasicInfo(cafeVM: cafeVM)
                .padding(.top, 20)
            Divider()
            CafeDetailInfo(cafeVM: cafeVM)
                .padding(.vertical, 35)
        }
    }
}
