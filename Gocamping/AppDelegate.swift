//
//  AppDelegate.swift
//  Gocamping
//
//  Created by 康 on 2023/7/24.
//

import UIKit
import GoogleMaps
import Firebase
import FirebaseDatabase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

//123

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //GMSServices.provideAPIKey("AIzaSyDVJHn2Xi5nhzoeXtq3dGi4FSsFMyU-RE0")
        (sleep(1) != 0)
    
        FirebaseApp.configure()
            
//        ServeoManager.shared.serveoGroup.enter()
//        let ref = Database.database().reference()
//        ref.child("serveo_urls").child("url").observeSingleEvent(of: .value) { snapshot in
//            if let serveoURL = snapshot.value as? String {
//                let cleanedServeoURL = serveoURL.trimmingCharacters(in: .whitespacesAndNewlines)
//                ServeoManager.shared.setServeoURL(cleanedServeoURL)
//                ServeoManager.shared.updateNetworkManagerBaseURL()
//                print("成功取得 serveoURL: \(cleanedServeoURL)")
//                ServeoManager.shared.serveoGroup.leave()
//            } else {
//                print("無法取得 serveoURL")
//                ServeoManager.shared.serveoGroup.leave()
//            }
//        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

