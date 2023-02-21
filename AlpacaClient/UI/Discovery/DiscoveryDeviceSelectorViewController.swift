//
//  DiscoveryDeviceSelectorViewController.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 20.02.2023.
//

import Foundation
import UIKit
import Combine

class DiscoveryDeviceSelectorViewController: BaseViewController {
    var vmCreateHandler: DiscoveryDeviceSelectorViewModel.CreateHandler!
    private var viewModel: DiscoveryDeviceSelectorViewModel!
    
    private let viewDidAppearSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupView()
        setupNavigationBar()
        setupViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppearSubject.send()
    }
    
    private func setupView() {
        contentView.addSubview(activityIndicatorView)
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.setBottomBorderColor(color: .lightGray.withAlphaComponent(0.5), height: 1)
        
        navigationItem.title = "Device Selector"
    }
    
    private func setupViewModel() {
        viewModel = vmCreateHandler(viewDidAppearSubject.eraseToAnyPublisher())
        
        setupVMSubscriptions()
    }
    
    private func setupVMSubscriptions() {
        viewModel.statePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.update(with: state)
                Log.info(state)
            }
            .store(in: &cancellables)
    }
    
    private func update(with newState: DiscoveryDeviceSelectorViewModel.State) {
        if newState.isLoading {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
}
