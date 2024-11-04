import UIKit
import Foundation
import ImageIO
import MobileCoreServices

final class GifGenerator: GifGeneratorProtocol {
    
    var currentCanvas: CanvasView.Coordinator? = nil
    let group = DispatchGroup()
    
    private func addBackgroundImage(to images: [UIImage], backgroundImage: UIImage) -> [UIImage] {
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

    private func createGIF(from images: [UIImage], frameDelay: Double, loopCount: Int = 0) -> Data? {
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
    
    
    func gifCall(_ lines: [[Line]], delay: Double,
                 completion: @escaping (Data?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var images = [UIImage]()
            lines.forEach { value in
                self.group.enter()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.currentCanvas = CanvasView.Coordinator(canvas: UIImageView(),
                                                                tool: .pencil,
                                                                color: .red,
                                                                lineWidth: 1,
                                                                isDrawing: false, onLineAdded: { _ in
                        
                    })
                    self.currentCanvas?.lines = value
                    self.currentCanvas?.canvas.bounds = CGRect(x: 358, y: 628, width: 358, height: 628)
                    self.currentCanvas?.redrawCanvas()
                    if let image = self.currentCanvas?.canvas.image {
                        images.append(image)
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {
                if let bgImage = UIImage(named: "paper-background") {
                    images = self.addBackgroundImage(to: images, backgroundImage: bgImage)
                }
                if let gifData = GifGenerator().createGIF(from: images, frameDelay: 0.07) {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let gifURL = documentsDirectory.appendingPathComponent("animated.gif")
                    do {
                        try gifData.write(to: gifURL)
                        debugPrint("GIF создан и сохранен по пути: \(gifURL)")
                        completion(gifData)
                    } catch {
                        debugPrint("Ошибка при сохранении GIF: \(error)")
                        completion(nil)
                    }
                }
            }
        }
    }
}


