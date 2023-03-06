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
            try await getRemoteValue(for: "connected")
        }
        
        func connected(_ value: Bool) async throws {
            try await putRemoteValue(for: "connected", data: [
                "Connected": value.representForAPI()
            ])
        }
        
        func name() async throws -> String {
            try await getRemoteValue(for: "name")
        }
        
        func description() async throws -> String {
            try await getRemoteValue(for: "description")
        }
        
        func driverInfo() async throws -> String {
            try await getRemoteValue(for: "driverinfo")
        }
        
        func driverVersion() async throws -> String {
            try await getRemoteValue(for: "driverversion")
        }
        
        func interfaceVersion() async throws -> Int32 {
            try await getRemoteValue(for: "interfaceversion")
        }
        
        func buildActionURL(_ actionName: String) -> URL? {
            URL(string: "\(baseURLString)\(actionName)")
        }
        
        func getRemoteValue<ValueType: Decodable>(for action: String) async throws -> ValueType {
            guard let url = buildActionURL(action) else {
                throw ASCOMAlpaca.Error(message: "Invalid URL!", data: nil)
            }
            
            let value: ValueType = try await executeGetAction(url)
            return value
        }
        
        func putRemoteValue(for action: String, data: [String: String] = [:]) async throws {
            guard let url = buildActionURL(action) else {
                throw ASCOMAlpaca.Error(message: "Invalid URL!", data: nil)
            }
            
            try await executePutAction(url, data: data)
        }
    }
}

extension Bool {
    func representForAPI() -> String {
        String(self)
    }
}
