//
//  ShowMessageManager.swift
//  Gocamping
//
//  Created by 康 on 2023/8/9.
//

import UIKit

// MARK: - ShowMessageManager
class ShowMessageManager {

    // MARK: - Singleton Instance
    static let shared = ShowMessageManager()
    
    // MARK: - Show Basic Alert
    /// Show a basic alert with an "OK" button.
    func showAlert(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Show Delete Alert
    /// Show an alert with "Delete" and "Cancel" options.
    func showDeleteAlert(on viewController: UIViewController, title: String, message: String, confirmAction: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            confirmAction()
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Show Global Toast
    /// Show a toast message globally in the application.
    func showToastGlobal(message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.keyWindow else {
            return
        }
        
        let toastWidth: CGFloat = 300
        let toastLabel = UILabel(frame: CGRect(x: keyWindow.frame.width / 2 - toastWidth / 2,
                                               y: keyWindow.frame.height - 250,
                                               width: toastWidth,
                                               height: 35))
        configureToastLabel(toastLabel, with: message)
        
        keyWindow.addSubview(toastLabel)
        animateToastLabel(toastLabel)
    }
    
    // MARK: - Configure Toast Label
    /// Configure the appearance of the toast label.
    private func configureToastLabel(_ label: UILabel, with message: String) {
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont(name: "Montserrat-Light", size: 12.0)
        label.text = message
        label.alpha = 1.0
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
    }
    
    // MARK: - Animate Toast Label
    /// Animate the toast label to fade out.
    private func animateToastLabel(_ label: UILabel) {
        UIView.animate(withDuration: 2.0, delay: 0.1, options: .curveEaseOut, animations: {
            label.alpha = 0.0
        }, completion: { _ in
            label.removeFromSuperview()
        })
    }
}

