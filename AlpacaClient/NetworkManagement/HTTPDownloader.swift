//
//  HTTPDownloader.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 16.02.2023.
//

import Foundation

private let validStatus = 200...299

protocol HTTPDownloader {
    func httpData(for urlRequest: URLRequest) async throws -> Data
}

enum HTTPDownloaderError: Error {
    case httpError(response: Data?)
}

extension URLSession: HTTPDownloader {
    func httpData(for urlRequest: URLRequest) async throws -> Data {
        Log.API(request: urlRequest)
        
        guard let (data, response) = try await self.data(for: urlRequest, delegate: nil) as? (Data, HTTPURLResponse) else {
            throw HTTPDownloaderError.httpError(response: nil)
        }
        
        Log.API(response: response, object: data)
        
        guard validStatus.contains(response.statusCode) else {
            throw HTTPDownloaderError.httpError(response: data)
        }
        
        return data
    }
}
