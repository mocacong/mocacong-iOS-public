//
//  SwiftUIView.swift
//  mocacong
//
//  Created by Suji Lee on 2023/05/09.
//

import Foundation

struct CafeComments: Codable {
    var currentPage: Int?
    var isEnd: Bool?
    var comments: [Comment]?
    var count: Int?
}

