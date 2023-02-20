//
//  UINavigationBar + Extension.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 20.02.2023.
//

import Foundation
import UIKit

extension UINavigationBar {
  func setBottomBorderColor(color: UIColor, height: CGFloat) {
      let bottomBorderView = UIView(frame: CGRectZero)
      bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
      bottomBorderView.backgroundColor = color
      
      addSubview(bottomBorderView)
      
      let views = ["border": bottomBorderView]
      addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[border]|", options: [], metrics: nil, views: views))
      addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
      addConstraint(NSLayoutConstraint(item: bottomBorderView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: height))
  }
}
