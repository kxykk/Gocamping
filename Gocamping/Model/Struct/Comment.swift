//
//  ArticleComment.swift
//  Gocamping
//
//  Created by 康 on 2023/7/26.
//

import Foundation

struct Comment: Decodable {
    
    var comment_id: Int
    var user_id: Int
    var article_id: Int
    var comment: String
    
    enum CodingKeys: String, CodingKey {
        case comment_id
        case user_id
        case article_id
        case comment
        
        
    }
    
    
}

