//
//  Service.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 22.02.2023.
//

import Foundation

extension AlpacaDeviceAPI {
    class Service {
        struct Error: Swift.Error {
            let message: String
            let data: Data?
            
            lazy var dataString: String = {
                guard let data = data else {
                    return "no data"
                }
                
                return String(data: data, encoding: .utf8) ?? "no data"
            }()
            
            mutating func toString() -> String {
                "Error message:\(message)\nAdditional data:\(dataString)"
            }
        }
        
        struct ASCOMError: Swift.Error {
            let message: String
            let number: Int32
            
            func toString() -> String {
                "ASCOM error occured (\(number)): \(message)"
            }
        }
        
        private let baseURLString: String
        private var clientTransactionId = 0
        var networkManager = NetworkManager.shared
        
        init(alpacaHost: String, alpacaPort: UInt32, apiVersion: UInt32, deviceType: DeviceType, deviceNumber: UInt32) {
            baseURLString = "http://\(alpacaHost):\(alpacaPort)/api/v\(apiVersion)/\(deviceType.rawValue.lowercased())/\(deviceNumber)/"
        }
        
        func isConnected() async throws -> Bool {
            guard let url = buildActionURL("connected") else {
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
        
        func connected(_ value: Bool) async throws {
            guard let url = buildActionURL("connected") else {
                throw Error(message: "Invalid URL!", data: nil)
            }
            
            let (data, isSuccess) = await networkManager.put(url, data: buildBody(with: [
                "Connected": value
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
        
        func buildBody(with customEntries: [AnyHashable: Any]) -> [AnyHashable: Any] {
            clientTransactionId = clientTransactionId + 1
            
            return customEntries.merging([
                "ClientID": "123",
                "ClientTransactionID": clientTransactionId
            ]){ (current, _) in current }
        }
    }
}

extension AlpacaDeviceAPI {
    struct ApiPayload<ValueType: Decodable>: Decodable {
        let value: ValueType
        let errorNumber: Int32
        let errorMessage: String
        let clientTransactionId: UInt32
        let serverTransactionId: UInt32
        
        private enum CodingKeys: String, CodingKey {
            case Value
            case ErrorNumber
            case ErrorMessage
            case ClientTransactionID
            case ServerTransactionID
        }
        
        init(from decoder: Decoder) throws {
            let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
            
            if ValueType.self == NoValue.self {
                value = NoValue() as! ValueType
            } else {
                value = try rootContainer.decode(ValueType.self, forKey: .Value)
            }
            errorNumber = try rootContainer.decode(Int32.self, forKey: .ErrorNumber)
            errorMessage = try rootContainer.decode(String.self, forKey: .ErrorMessage)
            clientTransactionId = try rootContainer.decode(UInt32.self, forKey: .ClientTransactionID)
            serverTransactionId = try rootContainer.decode(UInt32.self, forKey: .ServerTransactionID)
        }
        
        func checkForASCOMError() throws {
            guard errorNumber != 0 else {
                return
            }
            
            throw Service.ASCOMError(message: errorMessage, number: errorNumber)
        }
    }
}

extension AlpacaDeviceAPI.NoValue: Decodable {
    init(from decoder: Decoder) throws {}
}
