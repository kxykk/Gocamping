//
//  User.swift
//  Gocamping
//
//  Created by 康 on 2023/7/26.
//

import Foundation

struct User: Decodable {
    let email: String
    let name: String
    let user_imageURL: String?
    let user_imageType: String?
    let user_imageSize: Int?
    let account_createDate: String
    let lastLoginDate: String?
    let user_id: Int
    let password: String
    let introduction: String?

    
    enum CodingKeys: String, CodingKey {
        case email
        case name
        case user_imageURL
        case user_imageType
        case user_imageSize
        case account_createDate
        case lastLoginDate
        case user_id
        case password
        case introduction
    }
}
