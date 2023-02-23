//
//  FocuserService.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 23.02.2023.
//

import Foundation

extension AlpacaDeviceAPI {
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
                throw Error(message: "Invalid URL!", data: nil)
            }
            
            let (data, isSuccess) = await networkManager.get(url)
            
            guard isSuccess else {
                throw Error(message: "Failed getting is connected status from remote!", data: data)
            }
            
            guard let data = data else {
                throw Error(message: "Response data isn't available!", data: nil)
            }
            
            guard let payload = ApiPayload<Bool>.decode(jsonData: data) else {
                throw Error(message: "Failed parsing the response data!", data: data)
            }
            
            try payload.checkForASCOMError()
            
            return payload.value
        }
    }
}
