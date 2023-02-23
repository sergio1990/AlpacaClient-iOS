//
//  AlpacaClientBaseAPIService.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 23.02.2023.
//

import Foundation

extension ASCOMAlpaca {
    class BaseAPIService {
        var networkManager: ASCOMAlpacaNetworkManagerProtocol = NetworkManager.shared
        var clientTransactionInfo = ClientTransactionInfo.shared
        
        func buildBody(with customEntries: [String: String] = [:]) async -> [String: String] {
            let transactioID = await clientTransactionInfo.nextTransactionID()
            
            return customEntries.merging([
                "ClientID": String(clientTransactionInfo.clientID),
                "ClientTransactionID": String(transactioID)
            ]){ (current, _) in current }
        }
        
        func executeGetAction<ValueType: Decodable>(_ url: URL, data: [String: String] = [:]) async throws -> ValueType {
            let (data, isSuccess) = await networkManager.get(url, data: buildBody(with: data))
            
            guard isSuccess else {
                throw Error(message: "Failed getting data from remote!", data: data)
            }
            
            guard let data = data else {
                throw Error(message: "Response data isn't available!", data: nil)
            }
            
            guard let payload = ApiPayload<ValueType>.decode(jsonData: data) else {
                throw Error(message: "Failed parsing the response data!", data: data)
            }
            
            try payload.checkForASCOMError()
            
            return payload.value
        }
        
        func executePutAction(_ url: URL, data: [String: String]) async throws {
            let (data, isSuccess) = await networkManager.put(url, data: buildBody(with: data))
            
            guard isSuccess else {
                throw Error(message: "Failed putting data to remote!", data: data)
            }
            
            guard let data = data else {
                throw Error(message: "Response data isn't available!", data: nil)
            }
            
            guard let payload = ApiPayload<NoValue>.decode(jsonData: data) else {
                throw Error(message: "Failed parsing the response data!", data: data)
            }
            
            try payload.checkForASCOMError()
        }
    }
}
    
extension ASCOMAlpaca.BaseAPIService {
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
            
            throw ASCOMAlpaca.ASCOMError(message: errorMessage, number: errorNumber)
        }
    }
}
