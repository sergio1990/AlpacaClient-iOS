//
//  AlpacaManagementService.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 16.02.2023.
//

import Foundation

class AlpacaManagementService {
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
    
    func apiVersions() async throws -> AlpacaManagementApiVersions {
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
        
        guard let payload = AlpacaManagementApiVersionsPayload.decode(jsonData: data) else {
            throw Error(message: "Failed parsing the response data!", data: data)
        }
        
        return .init(versions: payload.value)
    }
}

private struct URLProvider {
    let apiVersions: URL?
    
    init(host: String, port: UInt16) {
        let hostAndPort = "http://\(host):\(port)"
        
        apiVersions =  URL(string: "\(hostAndPort)/management/apiversions")
    }
}

struct AlpacaManagementApiVersions {
    let versions: [UInt16]
}

private class AlpacaApiPayload: Decodable {
    let clientTransactionId: UInt32
    let serverTransactionId: UInt32
    
    private enum CodingKeys: String, CodingKey {
        case ClientTransactionID
        case ServerTransactionID
    }
    
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        clientTransactionId = try rootContainer.decode(UInt32.self, forKey: .ClientTransactionID)
        serverTransactionId = try rootContainer.decode(UInt32.self, forKey: .ServerTransactionID)
    }
}

private class AlpacaManagementApiVersionsPayload: AlpacaApiPayload {
    let value: [UInt16]
    
    private enum CodingKeys: String, CodingKey {
        case Value
    }
    
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        value = try rootContainer.decode([UInt16].self, forKey: .Value)
        
        try super.init(from: decoder)
    }
}
