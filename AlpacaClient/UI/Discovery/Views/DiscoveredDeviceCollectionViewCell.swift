//
//  DiscoveredDeviceCollectionViewCell.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 20.02.2023.
//

import Foundation
import UIKit

class DiscoveredDeviceCollectionViewCell: UICollectionViewCell {
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 5
        
        return stackView
    }()
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .black
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }
    
    func setup(with device: DiscoveryViewModel.DiscoveredDevice) {
        nameLabel.text = device.name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
    }
    
    private func setupView() {
        addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
}
