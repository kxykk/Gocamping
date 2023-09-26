//
//  CustomTabbarController.swift
//  Gocamping
//
//  Created by 康 on 2023/8/17.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        // 先隱藏通知
        if var viewControllers = self.viewControllers, viewControllers.count >= 4 {
                viewControllers.remove(at: 3)
                self.setViewControllers(viewControllers, animated: false)
            }
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        
        
        guard selectedViewController != viewController else {
            return true
        }
        
        if let navController = viewController as? UINavigationController {
            navController.popToRootViewController(animated: true)
        }
        
        let fromView = selectedViewController!.view
        let toView = viewController.view
        if let containerView = fromView?.superview {
            containerView.addSubview(toView!)
        }
        UIView.transition(from: fromView!, to: toView!, duration: 0.3, options: .transitionCrossDissolve, completion: nil)
        return true
    }



}
