//
//  DiscoveryCoordinator.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 18.02.2023.
//

import Foundation
import UIKit

class DiscoveryCoordinator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = DiscoveryViewController()
        viewController.viewModel = .init()
        
        navigationController.pushViewController(viewController, animated: false)
    }
}
