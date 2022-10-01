//
//  NoteCell.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 01.10.2022.
//

import UIKit

class NoteCell: UITableViewCell {

    static let reusedID = "NoteCell"

    let noteLabel = ABLabel(textAlignment: .left, fontSize: 16, numberOfLines: 2)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .systemGray6

        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        self.addSubview(noteLabel)

        self.selectionStyle = .none

        let padding: CGFloat = 20

        NSLayoutConstraint.activate([
            noteLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            noteLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            noteLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding)
        ])
    }
}
