//
//  UIView.swift
//  ar-test
//
//  Created by Kozo Yamagata on 2019/09/28.
//  Copyright © 2019 STEPHANUS IVAN. All rights reserved.
//

import UIKit

extension UIView {
    func snapshotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        guard let currentContext = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        layer.render(in: currentContext)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
