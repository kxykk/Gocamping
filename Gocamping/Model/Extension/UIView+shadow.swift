//
//  UIView+shadow.swift
//  Gocamping
//
//  Created by 康 on 2023/10/4.
//

import UIKit

extension UIView {
    
    func shadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 4.0
        self.layer.masksToBounds = false
    }
    
}
