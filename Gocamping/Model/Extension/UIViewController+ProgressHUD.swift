//
//  UIViewController+ProgressHUD.swift
//  Gocamping
//
//  Created by 康 on 2023/10/22.
//

import UIKit
import MBProgressHUD

extension UIViewController {
    // MARK: - MBProgressHUD Show Method
    func mbProgressHUD(text: String) {
        DispatchQueue.main.async {
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressHUD.label.text = text
            progressHUD.contentColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
    }
    // MARK: - MBProgressHUD Hide Method
    func hideProgressedHUD() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: false)
        }
    }
}
