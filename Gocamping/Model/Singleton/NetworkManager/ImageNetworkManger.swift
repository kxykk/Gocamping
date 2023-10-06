//
//  ImageNetworkManger.swift
//  Gocamping
//
//  Created by 康 on 2023/10/6.
//

import Foundation
import Alamofire

class ImageNetworkManager: BaseNetworkManager {
    
    static let shared = ImageNetworkManager()
    
    // MARK: - Property
    let imageSortNumberKey = "image_sortNumber"
    let imageURLKey = "imageURL"
    let imageFormatKey = "image_format"
    let imageSizeKey = "image_size"
    let imageTypeKey = "image_type"
    let mimeType = "image/jpeg"
    let articleIDKey = "article_id"
    let campIDKey = "camp_id"
    let campNameKey = "camp_name"


    
    // MARK: - URL
    var sentPhotoURL = baseURL + "/image/upload/"
    var imageURL = baseURL + "/image/"
    var getImageURL = baseURL + "/image/get/"
    var getImageByUserID = baseURL + "/image/get_by_user/"
    var getCampImageURL = baseURL + "/image/get_by_camp/"





        
    private override init() {
        super.init()
    }
    
    // MARK: - Post
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
    // MARK: - Get

    func getImage(articleID: Int, imageType: String, completion: @escaping DoneHandler) {
        let getImageParameters = [articleIDKey: articleID, imageTypeKey: imageType] as [String: Any]
        doGetWithParameters(getImageURL, parameters: getImageParameters, completion: completion)
    }
    
    func getImageURLByUserID(userID: Int, completion: @escaping DoneHandler) {
        let finalURL = getImageByUserID + String(userID)
        doGet(finalURL, completion: completion)
    }
    
    func getCampsImage(camp_id: Int, completion: @escaping DoneHandler) {
        let finalURL = getCampImageURL + String(camp_id)
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
    
    //MARK: - Download
    
    func downloadImage(imageURL: String, completion: @escaping DownloadHandler) {
        
        let fileURL = ImageNetworkManager.baseURL + saveImageURL + imageURL
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
}
