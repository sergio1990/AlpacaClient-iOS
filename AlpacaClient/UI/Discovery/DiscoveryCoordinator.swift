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
        
        viewController.vmCreateHandler = { input in
            let vmInput = DiscoveryViewModel.Input(refresh: input)
            let serviceContext: DiscoveryViewModel.ServiceContext = .init(
                discoveryService: .init(),
                managementService: .init()
            )
            
            return .init(
                input: vmInput,
                serviceContext: serviceContext,
                handlers: .init(
                    selectionHandler: self.discoveredDeviceSelectionHandler
                )
            )
        }
        
        navigationController.pushViewController(viewController, animated: false)
    }
    
    private func discoveredDeviceSelectionHandler(_ discoveredDevice: DiscoveryViewModel.DiscoveredDevice) {
        let viewController = DiscoveryDeviceSelectorViewController()
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
