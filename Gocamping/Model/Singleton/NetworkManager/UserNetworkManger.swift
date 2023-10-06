//
//  UserNetworkManger.swift
//  Gocamping
//
//  Created by 康 on 2023/10/6.
//

import Foundation
import Alamofire

class UserNetworkManager: BaseNetworkManager {
    
    static let shared = UserNetworkManager()
    
    // MARK: - Property
    let emailKey = "email"
    let passwordKey = "password"
    let nameKey = "name"
    let account_createDateKey = "account_createDate"
    let articleIDKey = "article_id"

    
    // MARK: - URL
    var userURL = baseURL + "/user/"
    var searchUserURL = baseURL + "/user/search/"
    var loginURL = baseURL + "/user/login/"
    var getUserByArticleIDURL = baseURL + "/user/by_article/"
    var putUserIntroductionURL = baseURL + "/user/introduction/"

        
    private override init() {
        super.init()
    }
    
    // MARK: - Post
    func postUser(email: String, password: String, name: String, createDate: String, completion: DoneHandler?) {
        
        let  userParameters = [emailKey: email,
                            passwordKey: password,
                                nameKey: name,
                  account_createDateKey: createDate]
            
        doPost(userURL, parameters: userParameters, completion: completion)
        
    }
    
    func login(email: String, password: String, completion: DoneHandler?) {
        
        let loginParameters = [emailKey: email,
                            passwordKey: password]
        
        doPost(loginURL, parameters: loginParameters, completion: completion)
    }
    
    // MARK: - Get
    func getUser(userID: Int, completion: @escaping DoneHandler) {
        let finalURL = userURL + String(userID)
        doGet(finalURL, completion: completion)
    }
    
    func getUserByArticleID(articleID: Int, completion: @escaping DoneHandler) {
        
        let getUserURL = getUserByArticleIDURL + String(articleID)
        let parameters = [articleIDKey: articleID]
        
        doGetWithParameters(getUserURL, parameters: parameters, completion: completion)
    }
    
    func searchUser(email: String, completion: @escaping DoneHandler) {
        let parameters = [emailKey: email]
        doGetWithParameters(searchUserURL, parameters: parameters, completion: completion)
    }
    
    // MARK: - Delete
    func deleteUser(userID: Int, completion: DoneHandler?) {
        let finalURL = userURL + String(userID)
        doDelete(finalURL, completion: completion)
    }
    
    //MARK: - Put
    func putUserIntroduction(userID: Int, introduction: String, completion: DoneHandler?) {
        let finalURL = putUserIntroductionURL + String(userID)
        let parameters = [introductionKey: introduction] as [String: Any]
        doPut(finalURL, parameters: parameters, completion: completion)
    }
    
}
