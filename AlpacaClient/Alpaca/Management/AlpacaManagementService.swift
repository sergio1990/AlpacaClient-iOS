//
//  AlpacaManagementService.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 16.02.2023.
//

import Foundation

class AlpacaManagementService {
    private let urlProvider: URLProvider
    
    var networkManager = NetworkManager.shared
    
    init(host: String, port: UInt16) {
        urlProvider = .init(host: host, port: port)
    }
    
    func apiVersions() async -> String {
        guard let url = urlProvider.apiVersions else {
            return "invalid url"
        }
        
        let (data, _) = await networkManager.get(url)
        
        guard let data = data else {
            return "no data"
        }
        
        guard let dataString = String(data: data, encoding: .utf8) else {
            return "invalid data"
        }
        
        return dataString
    }
}

private struct URLProvider {
    let apiVersions: URL?
    
    init(host: String, port: UInt16) {
        let hostAndPort = "http://\(host):\(port)"
        
        apiVersions =  URL(string: "\(hostAndPort)/management/apiversions")
    }
}
