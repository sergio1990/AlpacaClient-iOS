//
//  DiscoveryViewController.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 18.02.2023.
//

import Foundation
import UIKit
import Combine

class DiscoveryViewController: BaseViewController {
    var vmCreateHandler: DiscoveryViewModel.CreateHandler!
    private var viewModel: DiscoveryViewModel!
    
    private let refreshDidTapSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

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
        setupViewModel()
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
    
    private func setupViewModel() {
        viewModel = vmCreateHandler(refreshDidTapSubject.eraseToAnyPublisher())
        
        setupVMSubscriptions()
    }
    
    private func setupVMSubscriptions() {
        viewModel.statePublisher
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.update(with: state)
            }
            .store(in: &cancellables)
    }
    
    private func update(with newState: DiscoveryViewModel.State) {
        // Update refresh button animation
        if newState.isDiscovering {
            navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = false
            navigationItem.rightBarButtonItem?.customView?.rotate360Degrees()
        } else {
            navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = true
            navigationItem.rightBarButtonItem?.customView?.stopRotate360Degrees()
        }
        
        // Update message
        messageLabel.fadeTransition(0.3)
        if newState.isDiscovering {
            messageLabel.text = "Discovering 🔎...\n\n\nThe screen will be updated once something is found"
        } else {
            if newState.didTryDiscovery && newState.discoveredDevices.isEmpty {
                messageLabel.text = "Unfortunately, nothing has been found 🤷‍♂️"
            } else {
                messageLabel.text = "Please, trigger refresh in order to begin discovering Alpaca devices"
            }
        }
    }
    
    @objc private func updateDidTap() {
        refreshDidTapSubject.send()
    }
}
