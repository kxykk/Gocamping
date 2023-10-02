//
//  ShowMessageManager.swift
//  Gocamping
//
//  Created by 康 on 2023/8/9.
//

import UIKit

class ShowMessageManager {
    
    static let shared = ShowMessageManager()
    
    // 提示訊息
    func showAlert(on viewController: UIViewController, title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
    func showDeleteAlert(on viewController: UIViewController,title: String, message: String, confirmAction: @escaping () -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            confirmAction()
        }))
        
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
    func showToastGlobal(message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
        guard let keyWindow = windowScene.keyWindow else {
            return
        }
        
        let toastWidth: CGFloat = 300
        let toastLabel = UILabel(frame: CGRect(x: keyWindow.frame.width / 2 - toastWidth / 2,
                                               y: keyWindow.frame.height - 250,
                                               width: toastWidth,
                                               height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        keyWindow.addSubview(toastLabel)
        
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
} 
