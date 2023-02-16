//
//  ViewController.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 06.02.2023.
//

import UIKit
import Combine

class ViewController: UIViewController {
    private lazy var labelReady: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    private lazy var labelMessage: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    private lazy var labelReceive: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    private lazy var discoverButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .filled()
        button.setTitle("Discover", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    private var discoveryService: DiscoveryService?
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupView()
        prepareDiscoveryService()
        setupSubscriptions()
    }
    
    @objc private func buttonTapped(_ sender: Any) {
        discoveryService?.discover()
    }
    
    private func setupView() {
        discoverButton.isEnabled = false
        
        view.addSubview(labelReady)
        view.addSubview(labelMessage)
        view.addSubview(labelReceive)
        view.addSubview(discoverButton)
        
        NSLayoutConstraint.activate([
            labelReady.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            labelReady.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelMessage.topAnchor.constraint(equalTo: labelReady.bottomAnchor, constant: 40),
            labelMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelReceive.topAnchor.constraint(equalTo: labelMessage.bottomAnchor, constant: 40),
            labelReceive.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            discoverButton.topAnchor.constraint(equalTo: labelReceive.bottomAnchor, constant: 40),
            discoverButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func prepareDiscoveryService() {
        discoveryService = DiscoveryService()
        do {
            try discoveryService?.connect()
            discoverButton.isEnabled = true
            labelReady.text = "Ready to discover!"
        } catch {
            labelReady.text = "Failed init the discovery service!"
        }
    }
    
    private func setupSubscriptions() {
        discoveryService?.discoveryInfoPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak labelReceive] discoveryInfo in
                labelReceive?.text = discoveryInfo.toString()
                
                let managementService = AlpacaManagementService(host: discoveryInfo.host, port: discoveryInfo.port)
                
                Task {
                    do {
                        let apiVersionsResponse = try await managementService.apiVersions()
                        Log.info(apiVersionsResponse)
                        let descriptionResponse = try await managementService.description(version: apiVersionsResponse.versions[0])
                        Log.info(descriptionResponse)
                    } catch {
                        if var serviceError = error as? AlpacaManagementService.Error {
                            Log.error("Error when getting apiVersions!\n\(serviceError.toString())")
                        } else {
                            Log.error("Error when getting apiVersions!\n\(error.localizedDescription)")
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }
}
