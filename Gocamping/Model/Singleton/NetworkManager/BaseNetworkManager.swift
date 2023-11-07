//
//  BaseNetworkManager.swift
//  Gocamping
//
//  Created by 康 on 2023/10/6.
//

import Foundation
import Alamofire

typealias DoneHandler = (_ result: ServerResult?, _ statusCode: Int?, _ error: Error?) -> Void
typealias DownloadHandler = (_ data: Data?, _ error: Error?) -> Void

class BaseNetworkManager {
    
    var session: Session
    
//    #if DEBUG
//        static var baseURL: String = "http://localhost:8000"
//        var saveImageURL = "/Desktop/kang/Gocamping_Testapi/pictures/"
//    #else
        static var baseURL: String = "http://139.162.98.222:8000"
        var saveImageURL = "/root/Gocamping/Gocamping_api/pictures/"
//    #endif
    
    init() {
        let retrier = CustomsRetrier()
        session = Session(interceptor: retrier as? RequestInterceptor)
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
    
    
    func doGetWithParameters(_ urlString: String, parameters: [String: Any], completion: @escaping DoneHandler) {
        
        session.request(urlString,
                   method: .get,
                   parameters: parameters,
                   encoding:URLEncoding.default).responseDecodable {
            (response: DataResponse<ServerResult, AFError>) in
            self.handleResponse(response: response, completion: completion)
            
        }
        
    }
    
    func doGet(_ urlString: String, completion: @escaping DoneHandler) {
        
        session.request(urlString,
                   method: .get,
                   encoding:URLEncoding.default).responseDecodable {
            (response: DataResponse<ServerResult, AFError>) in
            self.handleResponse(response: response, completion: completion)
            
        }
        
    }
    
    func doPut(_ urlString: String, parameters: [String: Any], completion: DoneHandler?) {
        session.request(urlString,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default).responseDecodable {
            (response: DataResponse<ServerResult, AFError>) in
            self.handleResponse(response: response, completion: completion)
        }
    }
    
    func doDelete(_ urlString: String, completion: DoneHandler?) {
        
        session.request(urlString,
                   method: .delete).responseDecodable {
            (response: DataResponse<ServerResult, AFError>) in
            self.handleResponse(response: response, completion: completion)
        }
        
    }
    
    
    //MARK: - Response
    func handleResponse(response: DataResponse<ServerResult, AFError>, completion: DoneHandler?) {
        let statusCode = response.response?.statusCode
        
        switch response.result {
            
        case .success(let result):
            print("Success with: \(result)")
            completion?(result, statusCode, nil)
            
        case .failure(let error):
            print("Fail with: \(error)")
            completion?(nil, statusCode, error)
            
        }
        
    }
}

// MARK: - RequestRetrier
struct CustomsRetrier: RequestRetrier {
    func retry(_ request: Alamofire.Request, for session: Alamofire.Session, dueTo error: Error, completion: @escaping (Alamofire.RetryResult) -> Void) {
        if request.retryCount < 3 {
            completion(.retryWithDelay(3.0))
        } else {
            completion(.doNotRetry)
        }
    }
}
