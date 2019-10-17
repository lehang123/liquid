//
//  RBResizer.swift
//  ITProject
//
//  Created by Gong Lehan on 14/10/19.
//  Copyright © 2019 liquid. All rights reserved.
//

import UIKit

/// <#Description#>
class RBResizer {
    
    static func RBSquareImageTo(image: UIImage, size: CGSize) -> UIImage? {
        return RBResizeImage(image: RBSquareImage(image: image), targetSize: size)
    }

    static func RBSquareImage(image: UIImage) -> UIImage? {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        
        var edge: CGFloat
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }
        
        let posX = (originalWidth  - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0
        
        let cropSquare = CGRect(x: posX, y: posY, width: edge, height: edge)
        
        let imageRef = image.cgImage!.cropping(to: cropSquare);
        return UIImage(cgImage: imageRef!, scale: UIScreen.main.scale, orientation: image.imageOrientation)
    }
    
    /// Resizes an image
    /// - Parameter image: image to be resized
    /// - Parameter targetSize: the new size for the image
    static func RBResizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
        if let image = image {
            let size = image.size
            
            let widthRatio  = targetSize.width  / image.size.width
            let heightRatio = targetSize.height / image.size.height
            
            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
            }
            
            // This is the rect that we've calculated out and this is what is actually used below
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
        } else {
            return nil
        }
    }

    
}
