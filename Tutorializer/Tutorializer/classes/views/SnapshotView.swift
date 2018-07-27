//
//  SnapshotView.swift
//  Tutorializer
//
//  Created by Maxim Komlev on 7/17/18.
//  Copyright © 2018 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

class SnapshotView: UIImage {
    
    // MARK: Initializers/Deinitialier
    
    convenience init(view: UIView, scale: CGFloat = 0.0) {
        var image: UIImage!
        if #available(iOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat.default()
            format.scale = scale
            let renderer = UIGraphicsImageRenderer(bounds: view.bounds, format: format)
            image = renderer.image { rendererContext in
                view.layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale)
            if let cCtx = UIGraphicsGetCurrentContext() {
                view.layer.render(in: cCtx)
            }
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        self.init(cgImage: image.cgImage!)
    }
}
