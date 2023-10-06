//
//  ArticleNetworkManager.swift
//  Gocamping
//
//  Created by 康 on 2023/10/6.
//

import Foundation
import Alamofire

class ArticleNetworkManager: BaseNetworkManager {
    
    static let shared = ArticleNetworkManager()
    
    // MARK: - Property
    let titleKey = "article_title"
    let articleCreateDateKey = "article_createDate"
    let articleIDKey = "article_id"
    let userIDKey = "user_id"
    let keywordKey = "keyword"


    // MARK: - URL
    var articleURL = baseURL + "/article/"
    var getAllArticleURL = baseURL + "/article/all_ids_and_titles/"
    var getMyArticleURL = baseURL + "/article/by_user_id/"
    var deleteArticleContentURL = baseURL + "/article/delete_content/"
    var searchArticleURL = baseURL + "/article/search/"
    var getDetailsByArticleIDURL = baseURL + "/article/details/"
    
    var CollectionURL = baseURL + "/article_collection/"
    var getCollectedArticleURL = baseURL + "/article_collection/articles_by_userid/"

        
    private override init() {
        super.init()
    }
    
    // MARK: - Post
    func postArticle(title: String, userID: Int, createDate: String, completion: DoneHandler?) {
        
        let articleParameters = [titleKey: title,
                                userIDKey: userID,
                     articleCreateDateKey: createDate] as [String : Any]
        
        doPost(articleURL, parameters: articleParameters, completion: completion)
        
    }
    
    func postarticleCollection(articleID: Int, userID: Int, completion: DoneHandler?) {
        let parameters = [articleIDKey: articleID, userIDKey: userID]
        doPost(CollectionURL, parameters: parameters, completion: completion)
    }
    
    // MARK: - Get
    func getAllArticleIDandTitle(completion: @escaping DoneHandler) {
        doGet(getAllArticleURL, completion: completion)
        }
    
    func getMyArticle(userID: Int, completion: @escaping DoneHandler) {
        let parameters = [userIDKey: userID]
        doGetWithParameters(getMyArticleURL, parameters: parameters, completion: completion)
    }
    
    func searchArticles(keyword: String, completion: @escaping DoneHandler) {
        let parameters = [keywordKey: keyword]
        doGetWithParameters(searchArticleURL, parameters: parameters, completion: completion)
    }
    
    func getDetailsByArticleID(articleID: Int, completion: @escaping DoneHandler) {
        let finalURL = getDetailsByArticleIDURL + String(articleID)
        doGet(finalURL, completion: completion)
    }
    
    func getCollectedArticle(userID: Int, completion: @escaping DoneHandler) {
        let finalURL = getCollectedArticleURL + String(userID)
        doGet(finalURL, completion: completion)
    }
    
   // MARK: - Delete
    func deleteArticle(articleID: Int, completion: DoneHandler?) {
        let finalURL = articleURL + String(articleID)
        print("finalURL: \(finalURL)")
        doDelete(finalURL, completion: completion)
    }
    
    func deleteArticleContent(articleID: Int, completion: DoneHandler?) {
        let finalURL = deleteArticleContentURL + String(articleID)
        doDelete(finalURL, completion: completion)
    }
    
    func deleteCollectedArticle(articleID: Int, userID: Int, completion: DoneHandler?) {
        let finalURL = CollectionURL + String(articleID) + "/\(String(userID))"
        doDelete(finalURL, completion: completion)
    }
    
    // MARK: - Put

}

