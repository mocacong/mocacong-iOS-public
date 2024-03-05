//
//  Comment.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/29.
//

import Foundation

struct Comment: Codable, Hashable, Identifiable, IsMeProtocol {
    var id: Int?
    var imgUrl: String?
    var content: String?
    var nickname: String?
    var isMe: Bool?
    var userReportCount: Int?
}
