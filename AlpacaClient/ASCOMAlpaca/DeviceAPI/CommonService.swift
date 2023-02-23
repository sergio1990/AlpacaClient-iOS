//
//  Service.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 22.02.2023.
//

import Foundation

extension ASCOMAlpaca.DeviceAPI {
    class Service: ASCOMAlpaca.BaseAPIService {
        private let baseURLString: String
        private var clientTransactionId = 0
        
        init(alpacaHost: String, alpacaPort: UInt32, apiVersion: UInt32, deviceType: ASCOMAlpaca.DeviceType, deviceNumber: UInt32) {
            baseURLString = "http://\(alpacaHost):\(alpacaPort)/api/v\(apiVersion)/\(deviceType.rawValue.lowercased())/\(deviceNumber)/"
        }
        
        func isConnected() async throws -> Bool {
            guard let url = buildActionURL("connected") else {
                throw ASCOMAlpaca.Error(message: "Invalid URL!", data: nil)
            }
            
            let value: Bool = try await executeGetAction(url)
            return value
        }
        
        func connected(_ value: Bool) async throws {
            guard let url = buildActionURL("connected") else {
                throw ASCOMAlpaca.Error(message: "Invalid URL!", data: nil)
            }
            
            try await executePutAction(url, data: [
                "Connected": value.representForAPI()
            ])
        }
        
        func buildActionURL(_ actionName: String) -> URL? {
            URL(string: "\(baseURLString)\(actionName)")
        }
    }
}

extension Bool {
    func representForAPI() -> String {
        String(self)
    }
}
