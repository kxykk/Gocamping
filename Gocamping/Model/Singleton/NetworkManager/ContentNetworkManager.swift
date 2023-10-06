//
//  ContentNetworkManager.swift
//  Gocamping
//
//  Created by 康 on 2023/10/7.
//

import Foundation
import Alamofire

class ContentNetworkManager {
    
    static let shared = ContentNetworkManager()
    
    // MARK: - Post
    func postContent(articleID: Int, contents: [Content], completion: DoneHandler?) {
        
        var currentSortNumber = 1
        
        for content in contents {
            
            let imageType = "content"
            
            switch content {
                
            case .text(let contentText):
                
                TextNetworkManager.shared.postText(articleID: articleID, textSortNumber: currentSortNumber, content: contentText, completion: completion)
                currentSortNumber += 1
                
            case .image(let contentImage):
                
                if let resizeImage = contentImage.resize(maxEdge: 1024) {
                    if let jpgData = resizeImage.jpegData(compressionQuality: 0.6) {
                        ImageNetworkManager.shared.uploadImage(articleID: articleID, userID: nil, campID: nil, imageSortNumber: currentSortNumber, imageType: imageType, imageData: jpgData) { result, status, error  in
                            if let error = error {
                                assertionFailure("Upload image fail: \(error)")
                                return
                            }
                        }
                    }
                }
                currentSortNumber += 1
                
            }
        }
        
        
    }
    // MARK: - Put
    func updateArticleContent(articleID: Int, newContent: [Content], completion: DoneHandler?) {
        ArticleNetworkManager.shared.deleteArticleContent(articleID: articleID) { result, statusCode, error in
            if error == nil {
                self.postContent(articleID: articleID, contents: newContent, completion: completion)
            } else {
                completion?(nil, statusCode, error)
            }
        }
    }
}
