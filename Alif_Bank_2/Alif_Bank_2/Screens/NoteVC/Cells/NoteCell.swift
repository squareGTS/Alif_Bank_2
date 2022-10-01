//
//  NoteCell.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 01.10.2022.
//

import UIKit

class NoteCell: UITableViewCell {

    static let reusedID = "NoteCell"

    let viewBackground = UIView()

    var image = UIImageView()
    var label = ABLabel(textAlignment: .left, fontSize: 16, numberOfLines: 2)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        viewBackground.layer.cornerRadius = 10
        viewBackground.translatesAutoresizingMaskIntoConstraints = false
        viewBackground.backgroundColor = UIColor(named: "backgroundColor2")

        self.backgroundColor = .systemGray6

        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        addSubview(viewBackground)
        viewBackground.addSubview(label)
        viewBackground.addSubview(image)

        self.selectionStyle = .none

        let padding: CGFloat = 20

        NSLayoutConstraint.activate([
            viewBackground.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            viewBackground.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            viewBackground.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            viewBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),

            label.centerYAnchor.constraint(equalTo: viewBackground.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: viewBackground.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: image.trailingAnchor, constant: -20),

            image.centerYAnchor.constraint(equalTo: viewBackground.centerYAnchor),
            image.trailingAnchor.constraint(equalTo: viewBackground.trailingAnchor, constant: -padding),
            image.heightAnchor.constraint(equalToConstant: 24),
            image.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
}
