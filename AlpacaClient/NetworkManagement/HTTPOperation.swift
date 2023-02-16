//
//  HTTPOperation.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 16.02.2023.
//

import Foundation

class HTTPOperation: Operation {
    typealias Handler = (Data?, Bool) -> Void
    
    private let downloader: HTTPDownloader
    private let urlRequest: URLRequest
    private let handler: Handler
    private var _isFinished = false
    private var _isExecuting = false
    private var _isReady = false
    
    override var isExecuting: Bool {
        get { _isExecuting }
    }
    override var isFinished: Bool {
        get { _isFinished }
    }
    override var isAsynchronous: Bool {
        get { return true }
    }
    
    init(downloader: any HTTPDownloader = URLSession.shared, urlRequest: URLRequest, handler: @escaping Handler) {
        self.downloader = downloader
        self.urlRequest = urlRequest
        self.handler = handler
        
        super.init()
    }
    
    override func start() {
        if self.isCancelled {
            willChangeValue(for: \.isFinished)
            _isFinished = true
            didChangeValue(for: \.isFinished)
            return
        }
        
        main()
    }
    
    override func main() {
        if self.isCancelled {
            willChangeValue(for: \.isFinished)
            _isFinished = true
            didChangeValue(for: \.isFinished)
            return
        }
        
        willChangeValue(for: \.isExecuting)
        _isExecuting = true
        didChangeValue(for: \.isExecuting)
        
        Task {
            do {
                let data = try await downloader.httpData(for: urlRequest)
                handler(data, true)
            } catch HTTPDownloaderError.httpError(let data) {
                handler(data, false)
            }
            completeOperation()
        }
    }
    
    private func completeOperation() {
        willChangeValue(for: \.isExecuting)
        willChangeValue(for: \.isFinished)
        _isExecuting = false
        _isFinished = true
        didChangeValue(for: \.isExecuting)
        didChangeValue(for: \.isFinished)
    }
}
