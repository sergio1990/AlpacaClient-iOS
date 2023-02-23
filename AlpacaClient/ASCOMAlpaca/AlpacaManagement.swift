//
//  AlpacaManagement.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 16.02.2023.
//

import Foundation

extension ASCOMAlpaca {
    enum Management {
        struct Versions {
            let versions: [UInt16]
        }
        
        struct Description {
            let serverName: String
            let manufacturer: String
            let manufacturerVersion: String
            let location: String
        }
        
        struct ConfiguredDevice {
            let deviceName: String
            let deviceType: String
            let deviceNumber: UInt32
            let uniqueID: String
        }
    }
}
