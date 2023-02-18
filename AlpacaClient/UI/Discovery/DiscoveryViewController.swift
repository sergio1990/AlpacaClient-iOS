//
//  DiscoveryViewController.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 18.02.2023.
//

import Foundation
import UIKit

class DiscoveryViewController: UIViewController {
    var viewModel: DiscoveryViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        navigationItem.title = "Alpaca Client"
        
        let rightItem = UIBarButtonItem(image: UIImage(named: "Icons/refresh")?.resize(withSize: .init(width: 20, height: 20)), style: .plain, target: self, action: #selector(updateDidTap))
        rightItem.tintColor = .black
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.setRightBarButton(rightItem, animated: false)
    }
    
    @objc private func updateDidTap() {
        
    }
}
