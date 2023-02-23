//
//  ASCOMAlpaca.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 23.02.2023.
//

import Foundation

enum ASCOMAlpaca {
    enum DeviceType: String {
        case focuser = "Focuser"
    }
    
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
}

protocol ASCOMAlpacaNetworkManagerProtocol {
    func `get`(_ url: URL, data: [String: String]) async -> (Data?, Bool)
    func put(_ url: URL, data: [String: String]) async -> (Data?, Bool)
}
