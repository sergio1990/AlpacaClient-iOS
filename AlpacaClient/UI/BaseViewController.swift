//
//  BaseViewController.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 18.02.2023.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(contentView)
        
        let layoutGuider = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: layoutGuider.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: layoutGuider.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: layoutGuider.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: layoutGuider.bottomAnchor)
        ])
    }
}
