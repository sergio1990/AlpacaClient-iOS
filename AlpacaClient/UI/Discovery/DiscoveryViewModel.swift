//
//  DiscoveryViewModel.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 18.02.2023.
//

import Foundation
import Combine

typealias VoidPublisher = AnyPublisher<Void, Never>

class DiscoveryViewModel {
    typealias CreateHandler = (VoidPublisher) -> DiscoveryViewModel
    
    struct Input {
        let refresh: VoidPublisher
    }
    
    var statePublisher: AnyPublisher<State, Never>
    
    init(input: Input) {
        let sharedRefreshInput = input.refresh.share()
        
        let stateChangePublisher = sharedRefreshInput.map { StateChangeReason.refreshDidTrigger }
        let refreshTimeoutPublisher = sharedRefreshInput
            .map { StateChangeReason.refreshDidTimeout }
            .delay(for: .seconds(10), scheduler: RunLoop.main, options: .none)
        
        statePublisher = stateChangePublisher.merge(with: refreshTimeoutPublisher)
            .scan(State.default) { previousState, changeReason -> State in
                previousState.change(with: changeReason)
            }
            .prepend(State.default)
            .print("statePublisher")
            .eraseToAnyPublisher()
    }
}

extension DiscoveryViewModel {
    struct State {
        let isDiscovering: Bool
        let didTryDiscovery: Bool
        let discoveredDevices: [DiscoveredDevice]
        
        static let `default` = State(
            isDiscovering: false,
            didTryDiscovery: false,
            discoveredDevices: []
        )
        
        func change(with reason: StateChangeReason) -> Self {
            switch reason {
            case .refreshDidTrigger:
                return .init(
                    isDiscovering: true,
                    didTryDiscovery: didTryDiscovery,
                    discoveredDevices: discoveredDevices
                )
            case .refreshDidTimeout:
                return .init(
                    isDiscovering: false,
                    didTryDiscovery: true,
                    discoveredDevices: discoveredDevices
                )
            }
        }
    }
    
    enum StateChangeReason {
        case refreshDidTrigger
        case refreshDidTimeout
    }
    
    struct DiscoveredDevice {
        let host: String
        let port: UInt16
        let name: String
        let creator: String
        let version: String
        let apiVersion: UInt16
    }
}
