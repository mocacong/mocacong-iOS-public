//
//  CafeImages.swift
//  mocacong
//
//  Created by Suji Lee on 2023/05/24.
//

import Foundation
import SwiftUI
import Combine

struct CafeImageReview: Codable, Hashable {
    var isEnd: Bool?
    var cafeImages: [CafeImage]?
    var code: Int?
    var message: String?
    var userReportCount: Int?
    var noError: Bool?
}

struct CafeImage: Codable, Hashable, Identifiable, IsMeProtocol {
    var id: Int
    var imageUrl: String = ""
    var isMe: Bool?
}
