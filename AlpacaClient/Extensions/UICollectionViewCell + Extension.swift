//
//  UICollectionViewCell + Extension.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 20.02.2023.
//

import Foundation
import UIKit

protocol ReusableObject: AnyObject {
    static var reuseIdentifier: String { get }
}

extension ReusableObject {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}

extension UICollectionViewCell: ReusableObject {}
