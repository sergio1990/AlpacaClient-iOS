//
//  DiscoveryDeviceSelectorViewController.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 20.02.2023.
//

import Foundation
import UIKit

class DiscoveryDeviceSelectorViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.setBottomBorderColor(color: .lightGray.withAlphaComponent(0.5), height: 1)
        
        navigationItem.title = "Device Selector"
        
//        let refreshIcon = UIImage(named: "Icons/refresh")?.resize(withSize: .init(width: 20, height: 20))
//        let iconSize = CGRect(origin: .zero, size: refreshIcon!.size)
//        let iconButton = UIButton(frame: iconSize)
//        iconButton.addTarget(self, action: #selector(updateDidTap), for: .touchUpInside)
//
//        iconButton.setBackgroundImage(refreshIcon, for: [])
//
//        let rightItem = UIBarButtonItem(customView: iconButton)
//        rightItem.tintColor = .black
//
//        navigationItem.setHidesBackButton(true, animated: false)
//        navigationItem.setRightBarButton(rightItem, animated: false)
    }
}
