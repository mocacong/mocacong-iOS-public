//
//  Token.swift
//  mocacong
//
//  Created by Suji Lee on 12/14/23.
//

import Foundation

struct AccessInfo: Codable {
    var accessToken: String?
    var refreshToken: String?
    var userReportCount: Int?
}
