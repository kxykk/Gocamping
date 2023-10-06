//
//  ArticleManager.swift
//  Gocamping
//
//  Created by 康 on 2023/10/6.
//

import Foundation

class ArticleManager {
    
    static let shared = ArticleManager()
    
    var allArticle = [Articles]()
    
    var myArticle = [Articles]()
    
    var myCollectedArticle = [Articles]()
    
    var createArticleID = 0
}
