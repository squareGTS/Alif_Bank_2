//
//  MessageCell.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 01.10.2022.
//

import UIKit

class MessageCell: UITableViewCell {

    static let reusedID = "MessageCell"

    let senderLabel = ABLabel(textAlignment: .left, fontSize: 14, numberOfLines: 2)
    let messageLabel = ABLabel(textAlignment: .left, fontSize: 12, numberOfLines: 3)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .systemGray6

        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        self.addSubview(senderLabel)
        self.addSubview(messageLabel)

        self.selectionStyle = .none

        let padding: CGFloat = 6

        NSLayoutConstraint.activate([
            senderLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            senderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            senderLabel.trailingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -padding),
            senderLabel.heightAnchor.constraint(equalToConstant: 60),

            messageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            messageLabel.widthAnchor.constraint(equalToConstant: self.frame.width / 2),
            messageLabel.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
