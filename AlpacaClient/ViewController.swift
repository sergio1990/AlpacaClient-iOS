//
//  ViewController.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 06.02.2023.
//

import UIKit
import Network
import CocoaAsyncSocket

class ViewController: UIViewController {
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelReceive: UILabel!
    @IBOutlet weak var labelReady: UILabel!
    
    var udpSocket: GCDAsyncUdpSocket?
    var tag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        prepareUDPSocket()
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        let messageToUDP = "alpacadiscovery1"
        sendToUDPSocket(messageToUDP)
    }

    private func prepareUDPSocket() {
        udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: .main)
        do {
            try udpSocket?.bind(toPort: 0)
            print("Success bind to port!")
        } catch {
            print("Failed to bind to port!")
        }
        do {
            try udpSocket?.enableBroadcast(true)
            print("Success enabled broadcast!")
        } catch {
            print("Failed to enable broadcast!")
        }
        do {
            try udpSocket?.beginReceiving()
            print("Success begin receiving!")
        } catch {
            print("Failed to begin receiving!")
        }
    }
    
    private func sendToUDPSocket(_ content: String) {
        guard let contentToSendUDP = content.data(using: String.Encoding.utf8) else {
            return
        }
        
        print("Trying to send \(content)")
        udpSocket?.send(contentToSendUDP, toHost: "192.168.1.255", port: 32227, withTimeout: -1, tag: tag)
        tag += 1
    }
}

extension ViewController: GCDAsyncUdpSocketDelegate {
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        print("Did close due to \(error?.localizedDescription)")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        print("Did connect!")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        print("Did not connect due to \(error?.localizedDescription)")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        print("Did not send due to \(error?.localizedDescription)")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("Did send data with tag \(tag)")
        labelMessage.text = "Sent with the tag \(tag)"
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        let stringData = String(data: data, encoding: .utf8)
        
        let addrBytes = address[4...7]
        let portBytes = address[2...3]
        
        let hostString = addrBytes
            .map { String($0) }
            .joined(separator: ".")
        let port = UInt16(bigEndian: portBytes.withUnsafeBytes { $0.pointee })
        
        print("Received \(stringData) from \(hostString):\(port)")
        labelReceive.text = stringData
    }
}
