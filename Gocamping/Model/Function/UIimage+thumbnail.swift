//
//  UIimage+thumbnail.swift
//  Gocamping
//
//  Created by 康 on 2023/9/6.
//

import UIKit

extension UIImage {
    
    static func thumbnail(from image: UIImage) -> UIImage? {
        
        
        let thumbnailSize = CGSize(width:55, height: 55);
        let scale = UIScreen.main.scale
        
        
        UIGraphicsBeginImageContextWithOptions(thumbnailSize,false,scale)
        
        
        let widthRatio = thumbnailSize.width / image.size.width;
        let heightRadio = thumbnailSize.height / image.size.height;
        
        let ratio = max(widthRatio,heightRadio);
        
        let imageSize = CGSize(width:image.size.width*ratio,height: image.size.height*ratio);
        
        
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0,y: 0,width: thumbnailSize.width,height: thumbnailSize.height))
        circlePath.addClip()
        
        
        image.draw(in:CGRect(x: -(imageSize.width-thumbnailSize.width)/2.0,y: -(imageSize.height-thumbnailSize.height)/2.0,
                             width: imageSize.width,height: imageSize.height))
        //取得畫布上的縮圖
        let smallImage = UIGraphicsGetImageFromCurrentImageContext();
        //關掉畫布
        UIGraphicsEndImageContext();
        return smallImage
        
    }
}
