//
//  AlpacaDiscovery.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 16.02.2023.
//

import Foundation

extension ASCOMAlpaca {
    enum Discovery {
        struct Info {
            let host: String
            let port: UInt16
            
            func toString() -> String {
                "\(host):\(port)"
            }
        }
    }
}
