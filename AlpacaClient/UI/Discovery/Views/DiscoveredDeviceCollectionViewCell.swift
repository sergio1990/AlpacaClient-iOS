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
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 4
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
        nameLabel.attributedText = NSAttributedString(string: device.name, attributes: [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 14, weight: .regular)
        ])
        
        let descriptionText = "\(device.version)\nby \(device.creator)\nremote addr: \(device.remoteAddr)\napi version: v\(device.apiVersion)"
        descriptionLabel.attributedText = NSAttributedString(string: descriptionText, attributes: [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 10, weight: .light)
        ])
        descriptionLabel.layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        descriptionLabel.text = nil
    }
    
    private func setupView() {
        contentView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
}
