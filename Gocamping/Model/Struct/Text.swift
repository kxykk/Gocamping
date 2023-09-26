//
//  Text.swift
//  Gocamping
//
//  Created by 康 on 2023/7/26.
//

import Foundation

struct Text: Decodable {
    var text_id: Int
    var article_id: Int
    var text_sortNumber: Int
    var content: String
    
    enum CodingKeys: String,CodingKey {
        case text_id
        case article_id
        case text_sortNumber
        case content
    }
    
}
