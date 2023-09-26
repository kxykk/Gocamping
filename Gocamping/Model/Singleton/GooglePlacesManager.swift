//
//  GooglePlacesManager.swift
//  Gocamping
//
//  Created by 康 on 2023/9/19.
//

import Foundation
import Alamofire
//import GooglePlaces

class GooglePlacesmanager {
    static let shared = GooglePlacesmanager()
    private init() {}
    
    private let apiKey = "AIzaSyDVJHn2Xi5nhzoeXtq3dGi4FSsFMyU-RE0"
    
    func fetchPlaceID(keyword: String, completion: @escaping (String?) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
        let parameters: [String: Any] = ["input": keyword, "inputtype": "textquery", "fields": "place_id", "key": apiKey]
        
        AF.request(urlString, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let placeID = candidates.first?["place_id"] as? String {
                    completion(placeID)
                } else {
                    completion(nil)
                }
            case .failure(_):
                completion(nil)
            }
        }
        
    }
    
    func fetchPlacePhoto(placeID: String, completion: @escaping (Data?) -> Void) {
        let detailsURL = "https://maps.googleapis.com/maps/api/place/details/json"
        let detailsParameters: [String: Any] = ["place_id": placeID, "fields": "photo", "key": apiKey]
        
        
        AF.request(detailsURL, parameters: detailsParameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any],
                   let result = json["result"] as? [String: Any],
                   let photos = result["photos"] as? [[String: Any]],
                   let photoReference = photos.first?["photo_reference"] as? String {
                    
                    let photoURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(self.apiKey)"
                    
                    AF.request(photoURL).responseData { response in
                        switch response.result {
                        case .success(let data):
                            completion(data)
                        case .failure(let error):
                            completion(nil)
                        }
                    }
                    
                } else {
                    completion(nil)
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
}
