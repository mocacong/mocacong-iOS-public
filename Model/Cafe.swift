//
//  Cafe.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/29.
//

import Foundation

struct Cafe: Codable, Hashable {
    var mapId: String?
    var roadAddress: String?
    var phoneNumber: String?
    var name: String?
    var totalCount: Int?
    var favorite: Bool? //멤버가 이 카페를 즐겨찾는 카페로 설정했는지
    var favoriteId: Int?
    var score: Double?
    var myScore: Int?
    var studyType: String?
    var wifi: String?
    var parking: String?
    var toilet: String?
    var power: String?
    var sound: String?
    var desk: String?
    var reviewsCount: Int?
    var commentsCount: Int?
    var comments: Array<Comment>?
    var commentContents: Array<String>?
    var comment: String?
    var cafeImages: [CafeImage]? //5개만
    var userReportCount: Int?
}
