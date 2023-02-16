//
//  DiscoveryService.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 14.02.2023.
//

import Foundation
import CocoaAsyncSocket
import Combine

private let discoveryMessage = "alpacadiscovery1"
private let discoveryHort = "255.255.255.255"
private let discoveryPort: UInt16 = 32227

extension AlpacaDiscovery {
    class Service: NSObject {
        struct ConnectError: Error {}
        
        private let discoveryData: Data?
        private var udpSocket: GCDAsyncUdpSocket?
        private var tag: Int = 0
        private var isConnected = false
        
        private let discoveryInfoSubject = PassthroughSubject<Info, Never>()
        
        override init() {
            discoveryData = discoveryMessage.data(using: .utf8)
            
            super.init()
        }
        
        var discoveryInfoPublisher: AnyPublisher<Info, Never> {
            discoveryInfoSubject.eraseToAnyPublisher()
        }
        
        func connect() throws {
            guard !isConnected else {
                return
            }
            
            udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: .main)
            do {
                try udpSocket?.bind(toPort: 0)
                try udpSocket?.enableBroadcast(true)
                try udpSocket?.beginReceiving()
            } catch {
                throw ConnectError()
            }
            isConnected = true
        }
        
        func discover() {
            guard
                isConnected,
                let udpSocket = udpSocket,
                let discoveryData = discoveryData
            else {
                return
            }
            
            udpSocket.send(discoveryData, toHost: discoveryHort, port: discoveryPort, withTimeout: -1, tag: tag)
            tag += 1
        }
    }
}
    
extension AlpacaDiscovery.Service: GCDAsyncUdpSocketDelegate {
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        Log.severe("UDPSocket: did close due to \(error?.localizedDescription ?? "unknown") error")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        Log.info("UDPSocket: did connect!")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        Log.severe("UDPSocket: did not connect due to \(error?.localizedDescription ?? "unknown") error")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        Log.error("UDPSocket: did not send data with the tag \(tag) due to \(error?.localizedDescription ?? "unknown") error")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        Log.info("UDPSocket: did send data with tag \(tag)")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        guard
            let stringData = String(data: data, encoding: .utf8),
            address.count >= 16
        else {
            return
        }
        
        let addrBytes = address[4...7]
        let portBytes = address[2...3]
        
        let hostString = addrBytes
            .map { String($0) }
            .joined(separator: ".")
        let port = UInt16(bigEndian: portBytes.withUnsafeBytes { $0.pointee })
        
        Log.info("UDPSocket: Received \(stringData) from \(hostString):\(port)")
        
        guard let payload = AlpacaDiscovery.Payload.decode(jsonData: data) else {
            return
        }
        
        discoveryInfoSubject.send(.init(host: hostString, port: payload.alpacaPort))
    }
}

private extension AlpacaDiscovery {
    struct Payload: Decodable {
        let alpacaPort: UInt16
        
        private enum CodingKeys: String, CodingKey {
            case alpacaport
        }
        
        init(from decoder: Decoder) throws {
            let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
            
            alpacaPort = try rootContainer.decode(UInt16.self, forKey: .alpacaport)
        }
    }
}
