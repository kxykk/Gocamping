//
//  Content.swift
//  Gocamping
//
//  Created by 康 on 2023/8/23.
//

import Foundation
import UIKit

// Post cell model
enum Content {
    case text(String)
    case image(UIImage)
    
}

enum ContentType {
    case text(String)
    case image(Data)
}

// Get cell model

struct CombinedItem: Decodable {
    var type: String
    var item: Item
    var sortNumber: Int
    
    struct Item: Decodable {
        var article_id: Int?
        var text_sortNumber: Int?
        var content: String?
        var image_sortNumber: Int?
        var imageURL: String?
        var image_format: String?
        var image_size: Int?
        var image_type: String?
    }
}

