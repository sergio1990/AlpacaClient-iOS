//
//  DiscoveryDeviceSelectorViewController.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 20.02.2023.
//

import Foundation
import UIKit
import Combine

class DiscoveryDeviceSelectorViewController: BaseViewController {
    var vmCreateHandler: DiscoveryDeviceSelectorViewModel.CreateHandler!
    private var viewModel: DiscoveryDeviceSelectorViewModel!
    
    private let viewDidAppearSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var state = DiscoveryDeviceSelectorViewModel.State.default
    private var dataSource: UICollectionViewDiffableDataSource<Int, String>?
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        
        return view
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppearSubject.send()
    }
    
    private func setupView() {
        contentView.addSubview(collectionView)
        contentView.addSubview(activityIndicatorView)
        
        collectionView.register(ConfiguredDeviceCollectionViewCell.self, forCellWithReuseIdentifier: ConfiguredDeviceCollectionViewCell.reuseIdentifier)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            activityIndicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.setBottomBorderColor(color: .lightGray.withAlphaComponent(0.5), height: 1)
        
        navigationItem.title = "Device Selector"
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) { [weak self] collectionView, indexPath, deviceUniqID -> UICollectionViewCell? in
            let cellIdentifier = ConfiguredDeviceCollectionViewCell.reuseIdentifier
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ConfiguredDeviceCollectionViewCell else { return nil }
            guard let configuredDevice = self?.state.configuredDevices.first(where: { $0.uniqueID == deviceUniqID }) else { return cell }
            
            cell.setup(with: configuredDevice)
            return cell
        }
        
        collectionView.dataSource = dataSource
    }
    
    private func setupViewModel() {
        viewModel = vmCreateHandler(viewDidAppearSubject.eraseToAnyPublisher())
        
        setupVMSubscriptions()
    }
    
    private func setupVMSubscriptions() {
        viewModel.statePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.update(with: state)
                Log.info(state)
            }
            .store(in: &cancellables)
    }
    
    private func update(with newState: DiscoveryDeviceSelectorViewModel.State) {
        self.state = newState
        
        if newState.isLoading {
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
            activityIndicatorView.isHidden = true
        }
        
        applySnapshot()
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(state.configuredDevices.map(\.uniqueID), toSection: 0)

        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}
