//
//  UIImage+Resize.swift
//  Gocamping
//
//  Created by 康 on 2023/8/10.
//

import UIKit

extension UIImage {
    
    func resize(maxEdge: CGFloat) -> UIImage? {
        if self.size.width <= maxEdge && self.size.height <= maxEdge {
            return self
        }
        
        let ratio = self.size.width / self.size.height
        let finalSize: CGSize
        if self.size.width > self.size.height {
            let finalHeight = maxEdge / ratio
            finalSize = CGSize(width: maxEdge, height: finalHeight)
        } else {
            let finalWidth = maxEdge * ratio
            finalSize = CGSize(width: finalWidth, height: maxEdge)
        }
        
        UIGraphicsBeginImageContext(finalSize)
        let rect = CGRect(origin: .zero, size: finalSize)
        self.draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
        
    }
}
