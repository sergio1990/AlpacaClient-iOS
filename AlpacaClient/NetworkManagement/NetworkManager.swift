//
//  NetworkManager.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 16.02.2023.
//

import Foundation

class NetworkManager {
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        queue.name = "NetworkManager's queue"
        
        return queue
    }()
    
    static let shared: NetworkManager = NetworkManager()
    
    var downloader: HTTPDownloader = URLSession.shared
    
    func `get`(_ url: URL, data: [String: String] = [:]) async -> (Data?, Bool) {
        return await withCheckedContinuation({ continuation in
            let queryItems: [URLQueryItem] = data.map { .init(name: $0.key, value: $0.value) }
            let urlWithQueryItems = url.appending(queryItems: queryItems)
            var urlRequest = URLRequest(url: urlWithQueryItems)
            urlRequest.httpMethod = "GET"
            
            let operation = HTTPOperation(downloader: downloader, urlRequest: urlRequest) { data, isSuccess in
                continuation.resume(returning: (data, isSuccess))
            }
            
            operationQueue.addOperation(operation)
        })
    }
    
    func put(_ url: URL, data: [String: String]) async -> (Data?, Bool) {
        return await withCheckedContinuation({ continuation in
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "PUT"
            
            let bodyString = data
                .map { (key: AnyHashable, value: String) in
                    "\(key)=\(value)"
                }
                .joined(separator: "&")
            let bodyData = bodyString.data(using: .utf8)
            urlRequest.httpBody = bodyData
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue(String(format: "%lu", bodyData?.count ?? 0), forHTTPHeaderField: "Content-Length")
            
            let operation = HTTPOperation(downloader: downloader, urlRequest: urlRequest) { data, isSuccess in
                continuation.resume(returning: (data, isSuccess))
            }
            
            operationQueue.addOperation(operation)
        })
    }
}
