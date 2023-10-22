//
//  UserManager.swift
//  Gocamping
//
//  Created by 康 on 2023/10/6.
//

import Foundation

// MARK: - UserDefault
let userIDKey = "userID"
let userNameKey = "userName"
let introductionKey = "introduction"
let imageURLKey = "imageURL"
var userID = UserDefaults.standard.integer(forKey: userIDKey )
var userName = UserDefaults.standard.string(forKey: userNameKey)
var introduction = UserDefaults.standard.string(forKey: introductionKey)
var imageURL = UserDefaults.standard.string(forKey: imageURLKey)

class UserManager {
    static let shared = UserManager()
    var userObjectByArticleID: [Int: User] = [:]
    var userIDByArticleID: [Int: Int] = [:]
    
    var userByArticle = [User]()
}

