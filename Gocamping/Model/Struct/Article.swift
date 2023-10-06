//
//  Article.swift
//  Gocamping
//
//  Created by 康 on 2023/7/26.
//

import Foundation

struct Article: Decodable {
    var user_id: Int
    var article_createDate: String
    var article_title: String
    var article_id: Int
    

    enum CodingKeys: String, CodingKey {
        case user_id
        case article_createDate
        case article_title
        case article_id
        
    }
}

struct Articles: Codable {
    var article_id: Int
    var article_title: String
    
    enum CodingKeys: String, CodingKey {
        case article_id
        case article_title
    }
    
}
