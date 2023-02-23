//
//  AlpacaClientBaseAPIService.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 23.02.2023.
//

import Foundation

class AlpacaClientBaseAPIService {
    var networkManager = NetworkManager.shared
    var clientTransactionInfo = AlpacaClientTransactionInfo.shared
    
    func buildBody(with customEntries: [String: String] = [:]) async -> [String: String] {
        let transactioID = await clientTransactionInfo.nextTransactionID()
        
        return customEntries.merging([
            "ClientID": String(clientTransactionInfo.clientID),
            "ClientTransactionID": String(transactioID)
        ]){ (current, _) in current }
    }
}

extension AlpacaClientBaseAPIService {
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
    
    struct NoValue: Decodable {}
    
    struct ApiPayload<ValueType: Decodable>: Decodable {
        let value: ValueType
        let errorNumber: Int32?
        let errorMessage: String?
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
            errorNumber = try rootContainer.decodeIfPresent(Int32.self, forKey: .ErrorNumber)
            errorMessage = try rootContainer.decodeIfPresent(String.self, forKey: .ErrorMessage)
            clientTransactionId = try rootContainer.decode(UInt32.self, forKey: .ClientTransactionID)
            serverTransactionId = try rootContainer.decode(UInt32.self, forKey: .ServerTransactionID)
        }
        
        func checkForASCOMError() throws {
            guard let errorNumber = errorNumber, let errorMessage = errorMessage else {
                return
            }
            
            guard errorNumber != 0 else {
                return
            }
            
            throw ASCOMError(message: errorMessage, number: errorNumber)
        }
    }
}
