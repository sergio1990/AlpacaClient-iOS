//
//  DiscoveryViewController.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 18.02.2023.
//

import Foundation
import UIKit
import Combine

class DiscoveryViewController: BaseViewController {
    var vmCreateHandler: DiscoveryViewModel.CreateHandler!
    private var viewModel: DiscoveryViewModel!
    
    private let refreshDidTapSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var state = DiscoveryViewModel.State.default
    private var dataSource: UICollectionViewDiffableDataSource<Int, String>?

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.text = "Please, trigger refresh in order to begin discovering Alpaca devices"
        label.textColor = .black
        
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, repeatingSubitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = true
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupView()
        setupNavigationBar()
        setupDataSource()
        setupViewModel()
    }
    
    private func setupView() {
        contentView.addSubview(messageLabel)
        contentView.addSubview(collectionView)
        
        collectionView.register(DiscoveredDeviceCollectionViewCell.self, forCellWithReuseIdentifier: DiscoveredDeviceCollectionViewCell.reuseIdentifier)
        
        NSLayoutConstraint.activate([
            messageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.setBottomBorderColor(color: .lightGray.withAlphaComponent(0.5), height: 1)
        
        navigationItem.title = "Alpaca Discovery"
        
        let refreshIcon = UIImage(named: "Icons/refresh")?.resize(withSize: .init(width: 20, height: 20))
        let iconSize = CGRect(origin: .zero, size: refreshIcon!.size)
        let iconButton = UIButton(frame: iconSize)
        iconButton.addTarget(self, action: #selector(updateDidTap), for: .touchUpInside)
        
        iconButton.setBackgroundImage(refreshIcon, for: [])
        
        let rightItem = UIBarButtonItem(customView: iconButton)
        rightItem.tintColor = .black
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.setRightBarButton(rightItem, animated: false)
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) { [weak self] collectionView, indexPath, deviceUniqID -> UICollectionViewCell? in
            let cellIdentifier = DiscoveredDeviceCollectionViewCell.reuseIdentifier
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? DiscoveredDeviceCollectionViewCell else { return nil }
            guard let discoveredDevice = self?.state.discoveredDevices.first(where: { $0.uniqueID == deviceUniqID }) else { return cell }
            
            cell.setup(with: discoveredDevice)
            return cell
        }
    }
    
    private func setupViewModel() {
        viewModel = vmCreateHandler(refreshDidTapSubject.eraseToAnyPublisher())
        
        setupVMSubscriptions()
    }
    
    private func setupVMSubscriptions() {
        viewModel.statePublisher
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.update(with: state)
            }
            .store(in: &cancellables)
    }
    
    private func update(with newState: DiscoveryViewModel.State) {
        self.state = newState
        
        // Update refresh button animation
        if newState.isDiscovering {
            navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = false
            navigationItem.rightBarButtonItem?.customView?.rotate360Degrees()
        } else {
            navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = true
            navigationItem.rightBarButtonItem?.customView?.stopRotate360Degrees()
        }
        
        // Update message
        if newState.discoveredDevices.isEmpty {
            collectionView.isHidden = true
            messageLabel.isHidden = false
            
            messageLabel.fadeTransition(0.3)
            if newState.isDiscovering {
                messageLabel.text = "Discovering 🔎...\n\n\nThe screen will be updated once something is found"
            } else {
                if newState.didTryDiscovery {
                    messageLabel.text = "Unfortunately, nothing has been found 🤷‍♂️"
                } else {
                    messageLabel.text = "Please, trigger refresh in order to begin discovering Alpaca devices"
                }
            }
        } else {
            collectionView.isHidden = false
            messageLabel.isHidden = true
            
            messageLabel.text = nil
            
            applySnapshot()
        }
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(state.discoveredDevices.map(\.uniqueID), toSection: 0)

        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    
    @objc private func updateDidTap() {
        refreshDidTapSubject.send()
    }
}
