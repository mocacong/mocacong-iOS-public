//
//  Favorite.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/29.
//

import Foundation

struct Favorite: Codable, Hashable, Identifiable {
    var favoriteId: Int?
    var id: Int?
    var memberId: String?
    var cafeId: Int?
    var userReportCount: Int?
}
