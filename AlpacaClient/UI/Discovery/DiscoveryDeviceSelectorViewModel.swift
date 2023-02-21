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
            .delay(for: .seconds(2), scheduler: RunLoop.main, options: .none)
            .flatMap { _ in
                Future<StateChangeReason, Never> { promise in
                    Task {
                        let registeredDevicesResponse = try await serviceContext.managementService.configuredDevices(version: data.apiVersion)
                        Log.info(registeredDevicesResponse)
                        let registeredDevices = registeredDevicesResponse.map { registeredDeviceInfo in
                            RegisteredDevice(name: registeredDeviceInfo.deviceName)
                        }
                        promise(.success(.registeredDevicesDidFound(devices: registeredDevices)))
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
        let registeredDevices: [RegisteredDevice]
        
        static let `default` = State(
            registeredDevices: []
        )
        
        func change(with reason: StateChangeReason) -> Self {
            switch reason {
            case let .registeredDevicesDidFound(devices):
                var newRegisteredDevices = registeredDevices
                newRegisteredDevices.append(contentsOf: devices)
                
                return .init(registeredDevices: newRegisteredDevices)
            }
        }
    }
    
    enum StateChangeReason {
        case registeredDevicesDidFound(devices: [RegisteredDevice])
    }
    
    struct RegisteredDevice {
        let name: String
    }
}
