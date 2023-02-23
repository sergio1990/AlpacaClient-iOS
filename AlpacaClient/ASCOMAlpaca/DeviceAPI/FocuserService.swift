//
//  FocuserService.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 23.02.2023.
//

import Foundation

extension ASCOMAlpaca.DeviceAPI {
    class FocuserService: Service {
        init(alpacaHost: String, alpacaPort: UInt32, apiVersion: UInt32, deviceNumber: UInt32) {
            super.init(
                alpacaHost: alpacaHost,
                alpacaPort: alpacaPort,
                apiVersion: apiVersion,
                deviceType: .focuser,
                deviceNumber: deviceNumber
            )
        }
        
        func isMoving() async throws -> Bool {
            guard let url = buildActionURL("ismoving") else {
                throw ASCOMAlpaca.Error(message: "Invalid URL!", data: nil)
            }
            
            let value: Bool = try await executeGetAction(url)
            return value
        }
    }
}
