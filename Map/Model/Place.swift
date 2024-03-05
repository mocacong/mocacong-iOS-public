//
//  Place.swift
//  mocacong
//
//  Created by Suji Lee on 2023/04/11.
//

import Foundation
import MapKit

final class PlaceAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(place: Place) {
        self.title = place.placeName
        self.coordinate = CLLocationCoordinate2D(latitude: Double(place.y)!, longitude: Double(place.x)!)
    }
}

struct KakaoResponse: Codable, Hashable {
    var meta: Meta?
    var documents: Array<Place>?
}

struct CafePlace: Codable, Hashable, Identifiable {
    var id: String
    var addressName: String
    var phone: String
    var placeName: String
    var roadAddressName: String
    var x: String
    var y: String
    var solo: Bool = false
    var group: Bool = false
    var favorite: Bool = false
}

struct Place: Codable, Hashable, Identifiable {
    var addressName: String = ""
    var categoryGroupCode: String = ""
    var categoryGroup_name: String = ""
    var category_name: String = ""
    var distance: String = ""
    var id: String = ""
    var phone: String = ""
    var placeName: String = ""
    var placeUrl: String = ""
    var roadAddressName: String = ""
    var x: String = ""
    var y: String = ""
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case categoryGroupCode = "category_group_code"
        case categoryGroup_name = "category_group_name"
        case category_name = "category_name"
        case distance = "distance"
        case id = "id"
        case phone = "phone"
        case placeName = "place_name"
        case placeUrl = "place_url"
        case roadAddressName = "road_address_name"
        case x = "x"
        case y = "y"
    }
}

struct Meta: Codable, Hashable {
    var isEnd: Bool?
    var pageableCount: Int?
    var totalCount: Int?
    var sameName: SameName?
    
    enum CodingKeys: String, CodingKey {
        case isEnd = "is_end"
        case pageableCount = "pageable_count"
        case totalCount = "total_count"
        case sameName = "same_name"
    }
    
    struct SameName: Codable, Hashable {
        var region: [String]?
        var keyword: String?
        var selectedRegion: String?
        
        enum CodingKeys: String, CodingKey {
            case region = "region"
            case keyword = "keyword"
            case selectedRegion = "selected_region"
        }
    }
}
