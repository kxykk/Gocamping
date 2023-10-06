//
//  CommentNetworkManager.swift
//  Gocamping
//
//  Created by 康 on 2023/10/7.
//

import Foundation
import Alamofire

class CommentNetworkManager: BaseNetworkManager {
    
    static let shared = CommentNetworkManager()
    
    // MARK: - Property
    let articleIDKey = "article_id"
    let commentKey = "comment"
    let userIDKey = "user_id"
    
    // MARK: - URL
    var CommentURL = baseURL + "/comment/"
    var getCommentByArticleIDURL = baseURL + "/comment/by_article_id/"

    
    private override init() {
        super.init()
    }
    
    // MARK: - Post
    func postComment(articleID: Int, userID: Int, comment: String, completion: DoneHandler?) {
        
        let parameters = [articleIDKey: articleID, userIDKey: userID, commentKey: comment] as [String : Any]
        
        doPost(CommentURL, parameters: parameters, completion: completion)
        
    }
    // MARK: - Get
    func getCommentByArticleID(articleID: Int, completion: @escaping DoneHandler) {
        let finalURL = getCommentByArticleIDURL + String(articleID)
        doGet(finalURL, completion: completion)
    }
    
    // MARK: - Delete
    func deleteComment(commentID: Int, completion: DoneHandler?) {
        let finalURL = CommentURL + String(commentID)
        doDelete(finalURL, completion: completion)
    }
}
