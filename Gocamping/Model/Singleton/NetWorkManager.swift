//
//  NetWorkManager.swift
//  Gocamping
//
//  Created by 康 on 2023/7/28.
//
import Foundation
import Alamofire
import FirebaseDatabase

typealias DoneHandler = (_ result: ServerResult?, _ statusCode: Int?, _ error: Error?) -> Void
typealias DownloadHandler = (_ data: Data?, _ error: Error?) -> Void

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private var session: Session
    
    private init() {
        let retrier = CustomsRetrier()
        session = Session(interceptor: retrier as? RequestInterceptor)
    }
    
    
    let emailKey = "email"
    let passwordKey = "password"
    let nameKey = "name"
    let account_createDateKey = "account_createDate"
    
    let userIDKey = "user_id"
    let titleKey = "article_title"
    let articleCreateDateKey = "article_createDate"
    
    
    let articleIDKey = "article_id"
    let textSortNumberKey = "text_sortNumber"
    let contentKey = "content"
    
    let campIDKey = "camp_id"
    
    let imageSortNumberKey = "image_sortNumber"
    let imageURLKey = "imageURL"
    let imageFormatKey = "image_format"
    let imageSizeKey = "image_size"
    let imageTypeKey = "image_type"
    let mimeType = "image/jpeg"
    let introductionKey = "introduction"
    let commentKey = "comment"
    let keywordKey = "keyword"
    let campNameKey = "camp_name"

//#if DEBUG
//    static var baseURL: String = "http://localhost:8000"
//    var saveImageURL = "/Desktop/kang/Gocamping_Testapi/pictures/"
//#else
    static var baseURL: String = "http://139.162.98.222:8000"
    var saveImageURL = "/root/Gocamping/Gocamping_api/pictures/"
//#endif
    
    var userURL = baseURL + "/user/"
    var searchUserURL = baseURL + "/user/search/"
    var articleURL = baseURL + "/article/"
    var sentPhotoURL = baseURL + "/image/upload/"
    var textURL = baseURL + "/text/"
    var imageURL = baseURL + "/image/"
    var loginURL = baseURL + "/user/login/"
    var getAllArticleURL = baseURL + "/article/all_ids_and_titles/"
    var getImageURL = baseURL + "/image/get/"
    var getImageByUserID = baseURL + "/image/get_by_user/"
    var getUserByArticleIDURL = baseURL + "/user/by_article/"
    var getCampURL = baseURL + "/camp/"
    var getCampImageURL = baseURL + "/image/get_by_camp/"
    var getMyArticleURL = baseURL + "/article/by_user_id/"
    var getDetailsByArticleIDURL = baseURL + "/article/details/"
    var CommentURL = baseURL + "/comment/"
    var getCommentByArticleIDURL = baseURL + "/comment/by_article_id/"
    var deleteArticleContentURL = baseURL + "/article/delete_content/"
    var putUserIntroductionURL = baseURL + "/user/introduction/"
    var CollectionURL = baseURL + "/article_collection/"
    var getCollectedArticleURL = baseURL + "/article_collection/articles_by_userid/"
    var searchArticleURL = baseURL + "/article/search/"
    var searchCamps = baseURL + "/camp/search/"

    
    //MARK: Post
    func postUser(email: String, password: String, name: String, createDate: String, completion: DoneHandler?) {
        
        let  userParameters = [emailKey: email,
                            passwordKey: password,
                                nameKey: name,
                  account_createDateKey: createDate]
            
        doPost(userURL, parameters: userParameters, completion: completion)
        
    }
    
    
    
    func postArticle(title: String, userID: Int, createDate: String, completion: DoneHandler?) {
        
        let articleParameters = [titleKey: title,
                                userIDKey: userID,
                     articleCreateDateKey: createDate] as [String : Any]
        
        doPost(articleURL, parameters: articleParameters, completion: completion)
        
    }
    
    func postText(articleID: Int, textSortNumber: Int, content: String, completion: DoneHandler?) {
        
        let textParameters = [articleIDKey: articleID,
                         textSortNumberKey: textSortNumber,
                                contentKey: content] as [String : Any]
        
        doPost(textURL, parameters: textParameters, completion: completion)
    }
    
    
    func uploadImage(articleID: Int?, userID: Int?, campID: Int?, imageSortNumber: Int, imageType: String, imageData: Data, completion: DoneHandler?) {
        
        let filename = UUID().uuidString
        
        func prepareFormData(formData: MultipartFormData) {
            formData.append(imageData, withName: "file", fileName: "\(filename).jpg", mimeType: mimeType)
            if let articleID = articleID {
                formData.append("\(articleID)".data(using: .utf8)!, withName: articleIDKey)
            }
            if let userID = userID {
                formData.append("\(userID)".data(using: .utf8)!, withName: userIDKey)
            }
            if let campID = campID {
                formData.append("\(campID)".data(using: .utf8)!, withName: campIDKey)
            }
            formData.append("\(imageSortNumber)".data(using: .utf8)!, withName: imageSortNumberKey)
            formData.append(imageType.data(using: .utf8)!, withName: imageTypeKey)
        }
        
        session.upload(multipartFormData: prepareFormData(formData:), to: sentPhotoURL).responseDecodable { (response: DataResponse<ServerResult, AFError>) in
            self.handleResponse(response: response, completion: completion)
        }
        
    }
    // 這邊想要再根據如果有連續兩個textcell要合併在post
    func postContent(articleID: Int, contents: [Content], completion: DoneHandler?) {
        
        var currentSortNumber = 1
        
        for content in contents {
            
            let imageType = "content"
            
            switch content {
                
            case .text(let contentText):
                
                self.postText(articleID: articleID, textSortNumber: currentSortNumber, content: contentText, completion: completion)
                currentSortNumber += 1
                
            case .image(let contentImage):
                
                if let resizeImage = contentImage.resize(maxEdge: 1024) {
                    if let jpgData = resizeImage.jpegData(compressionQuality: 0.6) {
                        NetworkManager.shared.uploadImage(articleID: articleID, userID: nil, campID: nil, imageSortNumber: currentSortNumber, imageType: imageType, imageData: jpgData) { result, status, error  in
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
    
    func postComment(articleID: Int, userID: Int, comment: String, completion: DoneHandler?) {
        
        let parameters = [articleIDKey: articleID, userIDKey: userID, commentKey: comment] as [String : Any]
        
        doPost(CommentURL, parameters: parameters, completion: completion)
        
    }
    
    func login(email: String, password: String, completion: DoneHandler?) {
        
        let loginParameters = [emailKey: email,
                            passwordKey: password]
        
        doPost(loginURL, parameters: loginParameters, completion: completion)
    }
    
    func postarticleCollection(articleID: Int, userID: Int, completion: DoneHandler?) {
        let parameters = [articleIDKey: articleID, userIDKey: userID]
        doPost(CollectionURL, parameters: parameters, completion: completion)
    }
    
    //MARK: Get
    func getUser(userID: Int, completion: @escaping DoneHandler) {
        let finalURL = userURL + String(userID)
        doGet(finalURL, completion: completion)
    }
    
    func getAllArticleIDandTitle(completion: @escaping DoneHandler) {
        doGet(getAllArticleURL, completion: completion)
        }
    
    func getUserByArticleID(articleID: Int, completion: @escaping DoneHandler) {
        
        let getUserURL = getUserByArticleIDURL + String(articleID)
        print("getUserURL: \(getUserURL)")
        let parameters = [articleIDKey: articleID]
        
        doGetWithParameters(getUserURL, parameters: parameters, completion: completion)
        
    }
    
    func getImage(articleID: Int, imageType: String, completion: @escaping DoneHandler) {
        let getImageParameters = [articleIDKey: articleID, imageTypeKey: imageType] as [String: Any]
        doGetWithParameters(getImageURL, parameters: getImageParameters, completion: completion)
    }
    
    
    func getImageURLByUserID(userID: Int, completion: @escaping DoneHandler) {
        let finalURL = getImageByUserID + String(userID)
        doGet(finalURL, completion: completion)
    }
    
    func getCommentByArticleID(articleID: Int, completion: @escaping DoneHandler) {
        let finalURL = getCommentByArticleIDURL + String(articleID)
        doGet(finalURL, completion: completion)
    }
    
    func getCamps(completion: @escaping DoneHandler) {
        doGet(getCampURL, completion: completion)
    }
    
    func getCampsImage(camp_id: Int, completion: @escaping DoneHandler) {
        let finalURL = getCampImageURL + String(camp_id)
        doGet(finalURL, completion: completion)
    }
    
    func getMyArticle(userID: Int, completion: @escaping DoneHandler) {
        let parameters = [userIDKey: userID]
        doGetWithParameters(getMyArticleURL, parameters: parameters, completion: completion)
    }
    
    func getDetailsByArticleID(articleID: Int, completion: @escaping DoneHandler) {
        let finalURL = getDetailsByArticleIDURL + String(articleID)
        doGet(finalURL, completion: completion)
    }
    
    func getCollectedArticle(userID: Int, completion: @escaping DoneHandler) {
        let finalURL = getCollectedArticleURL + String(userID)
        doGet(finalURL, completion: completion)
    }
    
    func getCampImage(campID: Int, completion: @escaping DoneHandler) {
        let finalURL = getCampImageURL + String(campID)
        doGet(finalURL, completion: completion)
    }
    
    func getCampImage(campName: String, completion: @escaping DoneHandler) {
        let parameters = [campNameKey: campName]
        doGetWithParameters(getCampImageURL, parameters: parameters, completion: completion)
    }
    
    func searchArticles(keyword: String, completion: @escaping DoneHandler) {
        let parameters = [keywordKey: keyword]
        doGetWithParameters(searchArticleURL, parameters: parameters, completion: completion)
    }
    
    func searchCamps(keyword: String, completion: @escaping DoneHandler) {
        let parameters = [keywordKey: keyword]
        doGetWithParameters(searchCamps, parameters: parameters, completion: completion)
    }
    
    func searchUser(email: String, completion: @escaping DoneHandler) {
        let parameters = [emailKey: email]
        doGetWithParameters(searchUserURL, parameters: parameters, completion: completion)
    }
    
    //MARK: Download
    func downloadImage(imageURL: String, completion: @escaping DownloadHandler) {
        
        let fileURL = NetworkManager.baseURL + saveImageURL + imageURL
        session.request(fileURL).responseData { response in
            switch response.result {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func downloadOrLoadImage(imageURL: String, completion: @escaping DownloadHandler) {
        if let cacheImage = CacheManager.shared.load(filename: imageURL) {
            if let data = cacheImage.jpegData(compressionQuality: 1.0) {
                completion(data, nil)
                return
            }
        }
        self.downloadImage(imageURL: imageURL) { data, error in
            if let data = data {
                try? CacheManager.shared.save(data: data, filename: imageURL)
                completion(data, nil)
                return
            }
            completion(nil, error)
        }
    }
    
    func downloadCampImage(result: ServerResult?, completion: @escaping DownloadHandler) {
        guard let imageURL = result?.image?.imageURL else {
            print("Download fail!")
            return
        }
        session.request(imageURL).responseData { response in
            switch response.result {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    
    //MARK: Delete
    func deleteUser(userID: Int, completion: DoneHandler?) {
        let finalURL = userURL + String(userID)
        doDelete(finalURL, completion: completion)
    }
    
    func deleteArticle(articleID: Int, completion: DoneHandler?) {
        let finalURL = articleURL + String(articleID)
        print("finalURL: \(finalURL)")
        doDelete(finalURL, completion: completion)
    }
    
    func deleteArticleContent(articleID: Int, completion: DoneHandler?) {
        let finalURL = deleteArticleContentURL + String(articleID)
        doDelete(finalURL, completion: completion)
    }
    
    func deleteCollectedAerticle(articleID: Int, userID: Int, completion: DoneHandler?) {
        let finalURL = CollectionURL + String(articleID) + "/\(String(userID))"
        doDelete(finalURL, completion: completion)
    }
    
    func deleteComment(commentID: Int, completion: DoneHandler?) {
        let finalURL = CommentURL + String(commentID)
        doDelete(finalURL, completion: completion)
    }
    
    //MARK: Update
    func updateArticleContent(articleID: Int, newContent: [Content], completion: DoneHandler?) {
        deleteArticleContent(articleID: articleID) { result, statusCode, error in
            if error == nil {
                self.postContent(articleID: articleID, contents: newContent, completion: completion)
            } else {
                completion?(nil, statusCode, error)
            }
        }
    }
    
    //MARK: Put
    func putUserIntroduction(userID: Int, introduction: String, completion: DoneHandler?) {
        let finalURL = putUserIntroductionURL + String(userID)
        let parameters = [introductionKey: introduction] as [String: Any]
        doPut(finalURL, parameters: parameters, completion: completion)
    }
    
    //MARK: CRUD
    func doPost(_ urlString: String, parameters: [String: Any], completion: DoneHandler?) {
        
        session.request(urlString,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default).responseDecodable {
            (response: DataResponse<ServerResult, AFError>) in
            self.handleResponse(response: response, completion: completion)
        }
        
    }
    
    
    private func doGetWithParameters(_ urlString: String, parameters: [String: Any], completion: @escaping DoneHandler) {
        
        session.request(urlString,
                   method: .get,
                   parameters: parameters,
                   encoding:URLEncoding.default).responseDecodable {
            (response: DataResponse<ServerResult, AFError>) in
            self.handleResponse(response: response, completion: completion)
            
        }
        
    }
    
    private func doGet(_ urlString: String, completion: @escaping DoneHandler) {
        
        session.request(urlString,
                   method: .get,
                   encoding:URLEncoding.default).responseDecodable {
            (response: DataResponse<ServerResult, AFError>) in
            self.handleResponse(response: response, completion: completion)
            
        }
        
    }
    
    private func doPut(_ urlString: String, parameters: [String: Any], completion: DoneHandler?) {
        session.request(urlString,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default).responseDecodable {
            (response: DataResponse<ServerResult, AFError>) in
            self.handleResponse(response: response, completion: completion)
        }
    }
    
    private func doDelete(_ urlString: String, completion: DoneHandler?) {
        
        session.request(urlString,
                   method: .delete).responseDecodable {
            (response: DataResponse<ServerResult, AFError>) in
            self.handleResponse(response: response, completion: completion)
        }
        
    }
    
    
    //MARK: Response
    private func handleResponse(response: DataResponse<ServerResult, AFError>, completion: DoneHandler?) {
        let statusCode = response.response?.statusCode
        
        switch response.result {
            
        case .success(let result):
            print("Success with: \(result)")
            completion?(result,statusCode,nil)
            
        case .failure(let error):
            print("Fail with: \(error)")
            completion?(nil,statusCode,error)
            
        }
        
    }
    
}
//MARK: Struct

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

struct CustomsRetrier: RequestRetrier {
    func retry(_ request: Alamofire.Request, for session: Alamofire.Session, dueTo error: Error, completion: @escaping (Alamofire.RetryResult) -> Void) {
        if request.retryCount < 3 {
            completion(.retryWithDelay(3.0))
        } else {
            completion(.doNotRetry)
        }
    }
}


