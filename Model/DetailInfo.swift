//
//  Review.swift
//  mocacong
//
//  Created by Suji Lee on 2023/03/29.
//

import Foundation
import SwiftUI

struct Mocacong: Identifiable {
    var id = UUID().uuidString
    var image: Image = Image("Mocacong")
    var isTabbed: Bool = false
}

struct StudyType: Identifiable {
    
    var systemName: String = ""
    var id = UUID().uuidString
    var imageName: String = ""
    var label: String = ""
    var image: Image {
        return Image("\(imageName)")
    }
}

struct Wifi: Identifiable {
    var id = UUID().uuidString
    var imageName: String = ""
    var label: String = ""
    var image: Image {
        return Image("\(imageName)")
    }
}

struct Power: Identifiable {
    var id = UUID().uuidString
    var imageName: String = ""
    var image: Image {
        return Image("\(imageName)")
    }
    var isTabbed: Bool = false
}

struct Desk: Identifiable {
    var id = UUID().uuidString
    var imageName: String = ""
    var image: Image {
        return Image("\(imageName)")
    }
    var isTabbed: Bool = false
}

struct Sound: Identifiable {
    var id = UUID().uuidString
    var imageName: String = ""
    var image: Image {
        return Image("\(imageName)")
    }
    var isTabbed: Bool = false
}

struct Toilet: Identifiable {
    var id = UUID().uuidString
    var imageName: String = ""
    var image: Image {
        return Image("\(imageName)")
    }
    var isTabbed: Bool = false
}

struct Parking: Identifiable {
    var id = UUID().uuidString
    var imageName: String = ""
    var image: Image {
        return Image("\(imageName)")
    }
    var isTabbed: Bool = false
}

