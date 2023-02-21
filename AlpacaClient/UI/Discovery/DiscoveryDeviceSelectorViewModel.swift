//
//  DiscoveryDeviceSelectorViewModel.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 21.02.2023.
//

import Foundation
import Combine

class DiscoveryDeviceSelectorViewModel {
    typealias CreateHandler = (VoidPublisher) -> DiscoveryDeviceSelectorViewModel
    
    struct Data {
        let apiVersion: UInt16
    }
    
    struct Input {
        let viewDidAppear: VoidPublisher
    }
    
    struct ServiceContext {
        let managementService: AlpacaManagement.Service
    }
    
    struct Handlers {
    }
    
    var statePublisher: AnyPublisher<State, Never>
    
    private let handlers: Handlers
    
    init(data: Data, input: Input, serviceContext: ServiceContext, handlers: Handlers) {
        self.handlers = handlers
        
        let sharedViewDidLoadInput = input.viewDidAppear.share()
        
        let deviceDidFoundPublisher = sharedViewDidLoadInput
            .delay(for: .seconds(1), scheduler: RunLoop.main, options: .none)
            .flatMap { _ in
                Future<StateChangeReason, Never> { promise in
                    Task {
                        let configuredDevicesResponse = try await serviceContext.managementService.configuredDevices(version: data.apiVersion)
                        Log.info(configuredDevicesResponse)
                        let configuredDevices = configuredDevicesResponse.map { configuredDeviceInfo in
                            ConfiguredDevice(
                                name: configuredDeviceInfo.deviceName,
                                type: configuredDeviceInfo.deviceType,
                                number: configuredDeviceInfo.deviceNumber,
                                uniqueID: configuredDeviceInfo.uniqueID
                            )
                        }
                        promise(.success(.configuredDevicesDidFound(devices: configuredDevices)))
                    }
                }
            }
        
        statePublisher = deviceDidFoundPublisher
            .scan(State.default) { previousState, changeReason -> State in
                previousState.change(with: changeReason)
            }
            .prepend(State.default)
            .print("statePublisher")
            .eraseToAnyPublisher()
    }
}

extension DiscoveryDeviceSelectorViewModel {
    struct State {
        let isLoading: Bool
        let configuredDevices: [ConfiguredDevice]
        
        static let `default` = State(
            isLoading: true,
            configuredDevices: []
        )
        
        func change(with reason: StateChangeReason) -> Self {
            switch reason {
            case let .configuredDevicesDidFound(devices):
                var newConfiguredDevices = configuredDevices
                newConfiguredDevices.append(contentsOf: devices)
                
                return .init(
                    isLoading: false,
                    configuredDevices: newConfiguredDevices
                )
            }
        }
    }
    
    enum StateChangeReason {
        case configuredDevicesDidFound(devices: [ConfiguredDevice])
    }
    
    struct ConfiguredDevice {
        let name: String
        let type: String
        let number: UInt32
        let uniqueID: String
    }
}
