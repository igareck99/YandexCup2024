import UIKit
import Foundation
import ImageIO
import MobileCoreServices

final class GifGenerator {
    
    func addBackgroundImage(to images: [UIImage], backgroundImage: UIImage) -> [UIImage] {
        return images.map { image in
            let size = image.size
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            backgroundImage.draw(in: CGRect(origin: .zero, size: size))
            image.draw(in: CGRect(origin: .zero, size: size))
            let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return combinedImage ?? image
        }
    }

    func createGIF(from images: [UIImage], frameDelay: Double, loopCount: Int = 0) -> Data? {
        guard !images.isEmpty else { return nil }
        let fileProperties: CFDictionary = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: loopCount // 0 означает зацикливание
            ]
        ] as CFDictionary
        let frameProperties: CFDictionary = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: frameDelay
            ]
        ] as CFDictionary
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, kUTTypeGIF, images.count, nil) else {
            return nil
        }
        CGImageDestinationSetProperties(destination, fileProperties)
        for image in images {
            if let cgImage = image.cgImage {
                CGImageDestinationAddImage(destination, cgImage, frameProperties)
            }
        }
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        return data as Data
    }
    
    
    func gifCall() {
        
    }
}
