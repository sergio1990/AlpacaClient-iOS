//
//  AlpacaClientInfo.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 23.02.2023.
//

import Foundation

extension ASCOMAlpaca {
    actor ClientTransactionInfo {
        let clientID: UInt32
        private var clientTransactionID: UInt32
        
        static let shared = ClientTransactionInfo()
        
        init() {
            clientTransactionID = 0
            clientID = .random(in: 0...UInt32.max)
        }
        
        func nextTransactionID() -> UInt32 {
            clientTransactionID = clientTransactionID + 1
            return clientTransactionID
        }
    }
}
