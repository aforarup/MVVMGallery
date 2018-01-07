//
//  UIkitExtensions.swift
//  photoGallery
//
//  Created by Arup Saha on 04/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit
import CoreImage

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(_ className: T.Type) -> T {
        let reuseIdentifier = String(describing: T.self)
        guard let cell = self.dequeueReusableCell(withIdentifier: reuseIdentifier) as? T else {
            self.register(UINib(nibName: reuseIdentifier, bundle: Bundle.main), forCellReuseIdentifier: reuseIdentifier)
            guard let cell = self.dequeueReusableCell(withIdentifier: reuseIdentifier) as? T else {
                self.register(className, forCellReuseIdentifier: reuseIdentifier)
                return self.dequeueReusableCell(withIdentifier: reuseIdentifier) as! T
            }
            return cell
        }
        return cell
    }
}

extension UIImage {
    func changeBrightness(_ value: Float) -> UIImage {
        let context = CIContext(options: nil)
        let brightnessFilter: CIFilter = CIFilter(name: "CIColorControls")!
        brightnessFilter.setValue(CIImage(cgImage: self.cgImage!), forKey: "inputImage")

        brightnessFilter.setValue(value, forKey: "inputBrightness")
        let outputImage = brightnessFilter.outputImage!
        let imageRef = context.createCGImage(outputImage, from: outputImage.extent)
        return UIImage(cgImage: imageRef!)
    }
}
