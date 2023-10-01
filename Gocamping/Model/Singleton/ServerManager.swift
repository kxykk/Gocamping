//
//  ServerManager.swift
//  Gocamping
//
//  Created by 康 on 2023/9/22.
//

import Foundation

class ServeoManager {
    static let shared = ServeoManager()
    private var serveoURL: String?
    private var isServeoURLSet = false
    let serveoGroup = DispatchGroup()
    
    private init() {}
    
    func setServeoURL(_ url: String) {
        self.serveoURL = url
        self.isServeoURLSet = true
    }
    
    func getServeoURL() -> String? {
        return self.serveoURL
    }
    
    func canProcessWithNetworkOperation() -> Bool {
        return isServeoURLSet
    }
    
    func updateNetworkManagerBaseURL() {
            if let serveoURL = self.serveoURL {
//                NetworkManager.shared.updateBaseURL(newBaseURL: serveoURL)
            }
        }
    
}
