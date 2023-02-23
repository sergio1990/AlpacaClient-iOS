//
//  Service.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 22.02.2023.
//

import Foundation

extension AlpacaDeviceAPI {
    class Service: AlpacaClientBaseAPIService {        
        private let baseURLString: String
        private var clientTransactionId = 0
        
        init(alpacaHost: String, alpacaPort: UInt32, apiVersion: UInt32, deviceType: DeviceType, deviceNumber: UInt32) {
            baseURLString = "http://\(alpacaHost):\(alpacaPort)/api/v\(apiVersion)/\(deviceType.rawValue.lowercased())/\(deviceNumber)/"
        }
        
        func isConnected() async throws -> Bool {
            guard let url = buildActionURL("connected") else {
                throw Error(message: "Invalid URL!", data: nil)
            }
            
            let (data, isSuccess) = await networkManager.get(url, data: buildBody())
            
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
        
        func connected(_ value: Bool) async throws {
            guard let url = buildActionURL("connected") else {
                throw Error(message: "Invalid URL!", data: nil)
            }
            
            let (data, isSuccess) = await networkManager.put(url, data: buildBody(with: [
                "Connected": value.representForAPI()
            ]))
            
            guard isSuccess else {
                throw Error(message: "Failed getting is connected status from remote!", data: data)
            }
            
            guard let data = data else {
                throw Error(message: "Response data isn't available!", data: nil)
            }
            
            guard let payload = ApiPayload<NoValue>.decode(jsonData: data) else {
                throw Error(message: "Failed parsing the response data!", data: data)
            }
            
            try payload.checkForASCOMError()
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
