//
//  CampManager.swift
//  Gocamping
//
//  Created by 康 on 2023/7/26.
//

import Foundation

class CampManager {
    static let shared = CampManager()
    
    var camps = [Camp]()
    
}

struct Camp: Decodable {
    
    let camp_name: String
    let camp_city: String
    let camp_area: String
    let latitude_longitude_wgs84: String
    let camp_situation: String
    let camp_phone: String
    let camp_website: String?
    let camp_id: Int
    let camp_location: String

    enum CodingKeys: String, CodingKey {
        
        case camp_name
        case camp_city
        case camp_area
        case latitude_longitude_wgs84
        case camp_situation
        case camp_phone
        case camp_website
        case camp_id
        case camp_location
    }
}

