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
    
    struct ServiceContext {
        let discoveryService: AlpacaDiscovery.Service
        let managementService: AlpacaManagement.Service
    }
    
    struct Handlers {
        let selectionHandler: (DiscoveredDevice) -> Void
    }
    
    var statePublisher: AnyPublisher<State, Never>
    
    private let handlers: Handlers
    
    init(input: Input, serviceContext: ServiceContext, handlers: Handlers) {
        self.handlers = handlers
        
        let sharedRefreshInput = input.refresh.share()
        
        let refreshDidTriggerPublisher = sharedRefreshInput
            .map { [serviceContext] in
                do {
                    try serviceContext.discoveryService.connect()
                    serviceContext.discoveryService.discover()
                } catch {
                    Log.error("Error while discovering: \(error)")
                }
                
                return StateChangeReason.refreshDidTrigger
            }
        let refreshTimeoutPublisher = sharedRefreshInput
            .map { StateChangeReason.refreshDidTimeout }
            .delay(for: .seconds(5), scheduler: RunLoop.main, options: .none)
        
        let deviceDiscoveredPublisher = serviceContext.discoveryService.discoveryInfoPublisher
            .delay(for: .seconds(1), scheduler: RunLoop.main, options: .none)
            .flatMap({ [serviceContext] discoveryInfo in
                Future<StateChangeReason, Never> { promise in
                    serviceContext.managementService.configure(with: discoveryInfo.host, port: discoveryInfo.port)
                    
                    Task {
                        do {
                            let apiVersionsResponse = try await serviceContext.managementService.apiVersions()
                            Log.info(apiVersionsResponse)
                            let descriptionResponse = try await serviceContext.managementService.description(version: apiVersionsResponse.versions[0])
                            Log.info(descriptionResponse)
                            
                            let discoveredDevice: DiscoveredDevice = .init(
                                host: discoveryInfo.host,
                                port: discoveryInfo.port,
                                name: descriptionResponse.serverName,
                                creator: descriptionResponse.manufacturer,
                                version: descriptionResponse.manufacturerVersion,
                                apiVersion: apiVersionsResponse.versions[0]
                            )
                            promise(.success(StateChangeReason.deviceDidDiscover(device: discoveredDevice)))
                        } catch {
                            if var serviceError = error as? AlpacaManagement.Service.Error {
                                Log.error("Error when requesting management API!\n\(serviceError.toString())")
                            } else {
                                Log.error("Error when requesting management API!\n\(error.localizedDescription)")
                            }
                        }
                    }
                }
            })
        
        statePublisher = refreshDidTriggerPublisher.merge(with: refreshTimeoutPublisher, deviceDiscoveredPublisher)
            .scan(State.default) { previousState, changeReason -> State in
                previousState.change(with: changeReason)
            }
            .prepend(State.default)
            .print("statePublisher")
            .eraseToAnyPublisher()
    }
    
    func handleSelection(_ discoveredDevice: DiscoveredDevice) {
        handlers.selectionHandler(discoveredDevice)
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
                    discoveredDevices: []
                )
            case .refreshDidTimeout:
                return .init(
                    isDiscovering: false,
                    didTryDiscovery: true,
                    discoveredDevices: discoveredDevices
                )
            case let .deviceDidDiscover(device):
                var newDiscoveredDevices = discoveredDevices
                newDiscoveredDevices.append(device)
                
                return .init(
                    isDiscovering: isDiscovering,
                    didTryDiscovery: didTryDiscovery,
                    discoveredDevices: newDiscoveredDevices
                )
            }
        }
    }
    
    enum StateChangeReason {
        case refreshDidTrigger
        case refreshDidTimeout
        case deviceDidDiscover(device: DiscoveredDevice)
    }
    
    struct DiscoveredDevice {
        let host: String
        let port: UInt16
        let name: String
        let creator: String
        let version: String
        let apiVersion: UInt16
     
        var remoteAddr: String {
            "\(host):\(port)"
        }
        
        var uniqueID: String {
            [
                host,
                String(port),
                name,
                creator,
                version,
                String(apiVersion)
            ].joined(separator: "_")
        }
    }
}
