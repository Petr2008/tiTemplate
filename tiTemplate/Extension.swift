//
//  Extension.swift
//  tiTemplate
//
//  Created by Petr Gusakov on 21.10.2020.
//

import UIKit

extension FileManager {
    func removeItemIfExist(at url: URL) {
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            fatalError("\(error)")
        }
    }
}

extension UIImage {
    
    func crop(rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x *= self.scale
        rect.origin.y *= self.scale
        rect.size.width *= self.scale
        rect.size.height *= self.scale

        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}
