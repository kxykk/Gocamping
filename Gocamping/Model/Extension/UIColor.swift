//
//  UIColor.swift
//  Gocamping
//
//  Created by 康 on 2023/10/4.
//

import UIKit

extension UIColor {
    
    static var lightGreen: UIColor {
        return UIColor(red: 190/255, green: 207/255, blue: 105/255, alpha: 1.0)
    }
    
    static var cleanGreen: UIColor {
        return UIColor(red: 200/255, green: 234/255, blue: 209/255, alpha: 0.7)
    }
    
    static var peachCream: UIColor {
        return UIColor(red: 249/255, green: 225/255, blue: 187/255, alpha: 1.0)
    }
    
    static var mellowApricot: UIColor {
        return UIColor(red: 253/255, green: 206/255, blue: 180/255, alpha: 1.0)
    }
    
    static var flamingoPink: UIColor {
        return UIColor(red: 255/255, green: 191/255, blue: 179/255, alpha: 1.0)
    }
    
    static var sunsetOrange: UIColor {
        return UIColor(red: 255/255, green: 173/255, blue: 151/255, alpha: 1.0)
    }
    
    static var lightFlamingoPink: UIColor {
        let alpha: CGFloat = 0.2
        let flamingoPink = UIColor(red: 255/255, green: 191/255, blue: 179/255, alpha: 1.0)
        var newRed: CGFloat = 0, newGreen: CGFloat = 0, newBlue: CGFloat = 0, newAlpha: CGFloat = 0
        flamingoPink.getRed(&newRed, green: &newGreen, blue: &newBlue, alpha: &newAlpha)

        newRed = (1 - alpha) + alpha * newRed
        newGreen = (1 - alpha) + alpha * newGreen
        newBlue = (1 - alpha) + alpha * newBlue

        let lightFlamingoPink = UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
        
        return lightFlamingoPink
    }
    
}

