//
//  ServerResult.swift
//  Gocamping
//
//  Created by 康 on 2023/10/6.
//

import Foundation

struct ServerResult: Decodable {
    var success: Bool?
    var errorCode: String?
    var user: User?
    var article: Article?
    var articles: [Articles]?
    var text: Text?
    var image: Image?
    var combinedItems: [CombinedItem]?
    var camps: [Camp]?
    var comment: Comment?
    var comments: [Comment]?
    var statusCode: Int?
    
    enum CodingKeys: String, CodingKey {
        case success
        case errorCode
        case user
        case article
        case articles
        case text
        case image
        case combinedItems
        case camps
        case comment
        case comments
        case statusCode
    }
}
