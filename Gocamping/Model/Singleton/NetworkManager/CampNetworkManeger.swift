//
//  CampNetworkManeger.swift
//  Gocamping
//
//  Created by 康 on 2023/10/6.
//

import Foundation
import Alamofire

class CampNetworkManager: BaseNetworkManager {
    
    static let shared = CampNetworkManager()
    
    // MARK: - Property
    let keywordKey = "keyword"


    
    // MARK: - URL
    var getCampURL = baseURL + "/camp/"
    var searchCamps = baseURL + "/camp/search/"

        
    private override init() {
        super.init()
    }
    
    // MARK: - Post
    
    // MARK: - Get
    func getCamps(completion: @escaping DoneHandler) {
        doGet(getCampURL, completion: completion)
    }
    
    func searchCamps(keyword: String, completion: @escaping DoneHandler) {
        let parameters = [keywordKey: keyword]
        doGetWithParameters(searchCamps, parameters: parameters, completion: completion)
    }
    
}
