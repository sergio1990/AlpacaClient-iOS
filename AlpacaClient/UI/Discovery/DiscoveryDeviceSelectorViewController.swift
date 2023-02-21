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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppearSubject.send()
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
            .sink { state in
                Log.info(state)
            }
            .store(in: &cancellables)
    }
}
