//
//  ArticleManager.swift
//  Gocamping
//
//  Created by 康 on 2023/8/18.
//

import Foundation

class ArticleManager {
    
    static let shared = ArticleManager()
    
    var allArticle = [Articles]()
    
    var myArticle = [Articles]()
    
    var myCollectedArticle = [Articles]()
    
    var createArticleID = 0
}


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
