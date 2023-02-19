//
//  DiscoveryViewController.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 18.02.2023.
//

import Foundation
import UIKit

class DiscoveryViewController: BaseViewController {
    var viewModel: DiscoveryViewModel!
    
    private var isRefreshAnimating: Bool = false

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.text = "Please, trigger refresh in order to begin discovering Alpaca devices"
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupView()
        setupNavigationBar()
    }
    
    private func setupView() {
        contentView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        navigationItem.title = "Alpaca Discovery"
        
        let refreshIcon = UIImage(named: "Icons/refresh")?.resize(withSize: .init(width: 20, height: 20))
        let iconSize = CGRect(origin: .zero, size: refreshIcon!.size)
        let iconButton = UIButton(frame: iconSize)
        iconButton.addTarget(self, action: #selector(updateDidTap), for: .touchUpInside)
        
        iconButton.setBackgroundImage(refreshIcon, for: [])
        
        let rightItem = UIBarButtonItem(customView: iconButton)
        rightItem.tintColor = .black
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.setRightBarButton(rightItem, animated: false)
    }
    
    @objc private func updateDidTap() {
        if isRefreshAnimating {
            navigationItem.rightBarButtonItem?.customView?.stopRotate360Degrees()
        } else {
            navigationItem.rightBarButtonItem?.customView?.rotate360Degrees()
        }
        isRefreshAnimating = !isRefreshAnimating
    }
}
