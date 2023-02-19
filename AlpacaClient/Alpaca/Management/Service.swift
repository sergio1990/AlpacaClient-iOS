//
//  AlpacaManagementService.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 16.02.2023.
//

import Foundation

extension AlpacaManagement {
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
        
        private let urlProvider: URLProvider
        
        var networkManager = NetworkManager.shared
        
        init(host: String, port: UInt16) {
            urlProvider = .init(host: host, port: port)
        }
        
        func apiVersions() async throws -> Versions {
            guard let url = urlProvider.apiVersions else {
                throw Error(message: "Invalid URL!", data: nil)
            }
            
            let (data, isSuccess) = await networkManager.get(url)
            
            guard isSuccess else {
                throw Error(message: "Failed getting API versions from remote!", data: data)
            }
            
            guard let data = data else {
                throw Error(message: "Response data isn't available!", data: nil)
            }
            
            guard let payload = ApiPayload<[UInt16]>.decode(jsonData: data) else {
                throw Error(message: "Failed parsing the response data!", data: data)
            }
            
            return .init(versions: payload.value)
        }
        
        func description(version: UInt16) async throws -> Description {
            guard let url = urlProvider.description(version: version) else {
                throw Error(message: "Invalid URL!", data: nil)
            }
            
            let (data, isSuccess) = await networkManager.get(url)
            
            guard isSuccess else {
                throw Error(message: "Failed getting description from remote!", data: data)
            }
            
            guard let data = data else {
                throw Error(message: "Response data isn't available!", data: nil)
            }
            
            guard let payload = ApiPayload<Payload.DescriptionValue>.decode(jsonData: data) else {
                throw Error(message: "Failed parsing the response data!", data: data)
            }
            
            return .init(
                serverName: payload.value.serverName,
                manufacturer: payload.value.manufacturer,
                manufacturerVersion: payload.value.manufacturerVersion,
                location: payload.value.location
            )
        }
        
        func configuredDevices(version: UInt16) async throws -> [ConfiguredDevice] {
            guard let url = urlProvider.configuredDevices(version: version) else {
                throw Error(message: "Invalid URL!", data: nil)
            }
            
            let (data, isSuccess) = await networkManager.get(url)
            
            guard isSuccess else {
                throw Error(message: "Failed getting description from remote!", data: data)
            }
            
            guard let data = data else {
                throw Error(message: "Response data isn't available!", data: nil)
            }
            
            guard let payload = ApiPayload<[Payload.ConfiguredDeviceValue]>.decode(jsonData: data) else {
                throw Error(message: "Failed parsing the response data!", data: data)
            }
            
            return payload.value.map { configuredDevice in
                    .init(
                        deviceName: configuredDevice.deviceName,
                        deviceType: configuredDevice.deviceType,
                        deviceNumber: configuredDevice.deviceNumber,
                        uniqueID: configuredDevice.uniqueID
                    )
            }
        }
    }
}

private extension AlpacaManagement {
    struct URLProvider {
        let apiVersions: URL?
        
        private let hostAndPort: String
        
        init(host: String, port: UInt16) {
            hostAndPort = "http://\(host):\(port)"
            
            apiVersions = URL(string: "\(hostAndPort)/management/apiversions")
        }
        
        func description(version: UInt16) -> URL? {
            URL(string: "\(hostAndPort)/management/v\(version)/description")
        }
        
        func configuredDevices(version: UInt16) -> URL? {
            URL(string: "\(hostAndPort)/management/v\(version)/configureddevices")
        }
    }
    
    struct ApiPayload<ValueType: Decodable>: Decodable {
        let value: ValueType
        let clientTransactionId: UInt32
        let serverTransactionId: UInt32
        
        private enum CodingKeys: String, CodingKey {
            case Value
            case ClientTransactionID
            case ServerTransactionID
        }
        
        init(from decoder: Decoder) throws {
            let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
            
            value = try rootContainer.decode(ValueType.self, forKey: .Value)
            clientTransactionId = try rootContainer.decode(UInt32.self, forKey: .ClientTransactionID)
            serverTransactionId = try rootContainer.decode(UInt32.self, forKey: .ServerTransactionID)
        }
    }
    
    enum Payload {
        struct DescriptionValue: Decodable {
            let serverName: String
            let manufacturer: String
            let manufacturerVersion: String
            let location: String
            
            private enum CodingKeys: String, CodingKey {
                case ServerName
                case Manufacturer
                case ManufacturerVersion
                case Location
            }
            
            init(from decoder: Decoder) throws {
                let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
                
                serverName = try rootContainer.decode(String.self, forKey: .ServerName)
                manufacturer = try rootContainer.decode(String.self, forKey: .Manufacturer)
                manufacturerVersion = try rootContainer.decode(String.self, forKey: .ManufacturerVersion)
                location = try rootContainer.decode(String.self, forKey: .Location)
            }
        }
        
        struct ConfiguredDeviceValue: Decodable {
            let deviceName: String
            let deviceType: String
            let deviceNumber: UInt32
            let uniqueID: String
            
            private enum CodingKeys: String, CodingKey {
                case DeviceName
                case DeviceType
                case DeviceNumber
                case UniqueID
            }
            
            init(from decoder: Decoder) throws {
                let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
                
                deviceName = try rootContainer.decode(String.self, forKey: .DeviceName)
                deviceType = try rootContainer.decode(String.self, forKey: .DeviceType)
                deviceNumber = try rootContainer.decode(UInt32.self, forKey: .DeviceNumber)
                uniqueID = try rootContainer.decode(String.self, forKey: .UniqueID)
            }
        }
    }
}