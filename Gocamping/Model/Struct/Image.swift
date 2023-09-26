//
//  Image.swift
//  Gocamping
//
//  Created by 康 on 2023/7/26.
//

import Foundation

struct Image: Decodable {
    var article_id: Int?
    var user_id: Int?
    var image_sortNumber: Int
    var imageURL: String
    var image_format: String
    var image_size: Int
    var image_type: String
    
    enum CodingKeys: String, CodingKey {
        
        case article_id
        case user_id
        case image_sortNumber
        case imageURL
        case image_format
        case image_size
        case image_type

    }
}
