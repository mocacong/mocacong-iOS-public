//
//  Member.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/29.
//

import Foundation

struct Member: Hashable, Codable, Identifiable {
    var id: Int?
    var email: String?
    var password: String?
    var nickname: String?
    var phone: String?
    var platform: String?
    var platformId: String?
    var token: String?
    //Token
    var accessToken: String?
    var refreshToken: String?
    var isRegistered: Bool?
    var result: Bool?
    var imgUrl: String?
    var cafes: Array<Cafe>? //멤버가 리뷰한 카페들의 배열
    var userReportCount: Int?
}
