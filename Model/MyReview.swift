//
//  MyReview.swift
//  mocacong
//
//  Created by Suji Lee on 2023/04/26.
//

import Foundation

struct MyReview: Codable, Hashable {
    var isEnd: Bool?
    var cafes: [Review]?
}
