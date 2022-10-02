//
//  UserCell.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 02.10.2022.
//

import UIKit

class UserCell: UITableViewCell {

    static let reusedID = "UserCell"

    let userLabel = ABLabel(textAlignment: .left, fontSize: 14, numberOfLines: 2)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .systemGray6

        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        self.addSubview(userLabel)

        self.selectionStyle = .blue

        NSLayoutConstraint.activate([
            userLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            userLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}
