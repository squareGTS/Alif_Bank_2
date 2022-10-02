//
//  NoteVC.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 01.10.2022.
//

import UIKit

class NoteVC: UIViewController {

    let messageTextField = ABTextField()
    let saveButton = ABButton(backgroundColor: .systemRed, title: "Save")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Create"
        view.backgroundColor = .systemBackground

        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        configure()
    }

    @objc func savePressed() {
        FirebaseManager.shared.saveData(id: "",
                                        message: messageTextField,
                                        collection: "notes",
                                        curentStatus: "new") { error in
            if let err = error {
                self.presentABAlertOnMainThread(title: "Something went wrong",
                                                message: err.localizedDescription,
                                                buttonTitle: "Ok")
            } else {
                DispatchQueue.main.async {
                    self.messageTextField.text = ""
                }
            }
        }
    }

    private func configure() {
        view.addSubview(messageTextField)
        view.addSubview(saveButton)

        messageTextField.backgroundColor = .systemGray6

        let padding: CGFloat = 6

        NSLayoutConstraint.activate([
            messageTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height / 10),
            messageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            messageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            messageTextField.heightAnchor.constraint(equalToConstant: 100),

            saveButton.topAnchor.constraint(equalTo: messageTextField.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: messageTextField.leadingAnchor, constant: padding),
            saveButton.trailingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: -padding),
            saveButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
