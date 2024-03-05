//
//  MyReview.swift
//  mocacong
//
//  Created by Suji Lee on 2023/05/05.
//

import Foundation

struct Review: Codable, Hashable {
    var mapId: String?
    var name: String?
    var roadAddress: String?
    
    var myScore: Int? // 1~5
    var myStudyType: String? // solo, group, both
    var myWifi: String?       // 빵빵해요, 적당해요, 느려요
    var myParking: String?    // 여유로워요, 협소해요, 없어요
    var myToilet: String?     // 깨끗해요, 평범해요, 불편해요
    var myPower: String?      // 충분해요, 적당해요, 없어요
    var mySound: String?     // 조용해요, 적당해요, 북적북적해요
    var myDesk: String?      // 편해요, 보통이에요, 불편해요
}
