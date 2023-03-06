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
            try await getRemoteValue(for: "ismoving")
        }
        
        func halt() async throws {
            try await putRemoteValue(for: "halt")
        }
        
        func move(position: Int32) async throws {
            try await putRemoteValue(for: "move", data: [
                "Position": String(position)
            ])
        }
    }
}
