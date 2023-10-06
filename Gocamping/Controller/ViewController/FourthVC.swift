//
//  FourthViewController.swift
//  Gocamping
//
//  Created by 康 on 2023/7/24.
//

import UIKit

class FourthViewController: UIViewController {
    
    @IBOutlet var containerViews: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserViews), name: NSNotification.Name("userDidLogin"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: NSNotification.Name("userDidLogin"), object: nil)

        updateUserViews()

    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        updateUserViews()
        
    }
    

    
    @objc func updateUserViews() {
        let userID = UserDefaults.standard.integer(forKey: userIDKey)
        if userID != 0 {
            containerViews[0].isHidden = false
            containerViews[1].isHidden = true
            
        } else {
            containerViews[0].isHidden = true
            containerViews[1].isHidden = false
        }
    }
    @objc func loginSuccess() {
        if let hasUserName = userName {
            ShowMessageManager.shared.showToastGlobal(message: "登入成功 \(hasUserName)")
        }
    }
}
