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
    
    func `get`(_ url: URL) async -> (Data?, Bool) {
        return await withCheckedContinuation({ continuation in
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            
            let operation = HTTPOperation(downloader: downloader, urlRequest: urlRequest) { data, isSuccess in
                continuation.resume(returning: (data, isSuccess))
            }
            
            operationQueue.addOperation(operation)
        })
    }
}
