//
//  TextNetworkManager.swift
//  Gocamping
//
//  Created by 康 on 2023/10/7.
//

import Foundation
import Alamofire

class TextNetworkManager: BaseNetworkManager {
    
    static let shared = TextNetworkManager()
    
    // MARK: - Property
    let articleIDKey = "article_id"
    let textSortNumberKey = "text_sortNumber"
    let contentKey = "content"
    
    // MARK: - URL
    var textURL = baseURL + "/text/"


        
    private override init() {
        super.init()
    }
    
    // MARK: - Post
    func postText(articleID: Int, textSortNumber: Int, content: String, completion: DoneHandler?) {
        
        let textParameters = [articleIDKey: articleID,
                         textSortNumberKey: textSortNumber,
                                contentKey: content] as [String : Any]
        
        doPost(textURL, parameters: textParameters, completion: completion)
    }
    
    // MARK: - Get

    
}
