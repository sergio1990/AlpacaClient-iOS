//
//  UIImage + Extension.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 18.02.2023.
//

import Foundation
import UIKit

extension UIImage {
    func resize(withSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
