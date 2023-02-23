//
//  AlpacaManagementService.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 16.02.2023.
//

import Foundation

extension AlpacaManagement {
    class Service: AlpacaClientBaseAPIService {
        private var urlProvider: URLProvider
        
        override init() {
            urlProvider = .init(host: "", port: 0)
        }
        
        func configure(with host: String, port: UInt16) {
            urlProvider = .init(host: host, port: port)
        }
        
        func apiVersions() async throws -> Versions {
            guard let url = urlProvider.apiVersions else {
                throw Error(message: "Invalid URL!", data: nil)
            }
            
            let value: [UInt16] = try await executeGetAction(url)
            
            return .init(versions: value)
        }
        
        func description(version: UInt16) async throws -> Description {
            guard let url = urlProvider.description(version: version) else {
                throw Error(message: "Invalid URL!", data: nil)
            }
            
            let value: Payload.DescriptionValue = try await executeGetAction(url)
            
            return .init(
                serverName: value.serverName,
                manufacturer: value.manufacturer,
                manufacturerVersion: value.manufacturerVersion,
                location: value.location
            )
        }
        
        func configuredDevices(version: UInt16) async throws -> [ConfiguredDevice] {
            guard let url = urlProvider.configuredDevices(version: version) else {
                throw Error(message: "Invalid URL!", data: nil)
            }
            
            let value: [Payload.ConfiguredDeviceValue] = try await executeGetAction(url)
            
            return value.map { configuredDevice in
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
