//
//  NoteVC.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 01.10.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NoteVC: UIViewController {

    var messageTextField = ABTextField()
    var saveButton = ABButton(backgroundColor: .systemRed, title: "Save")

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        configure()
    }

    @objc func savePressed() {

        if let messageBody = messageTextField.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection("notes").addDocument(data: [
                "sender": messageSender,
                "body": messageBody,
                "date": Date().timeIntervalSince1970,
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("Successfully saved data.")

                    DispatchQueue.main.async {
                        self.messageTextField.text = ""
                    }
                }
            }
        }
    }

    private func configure() {
        view.addSubview(messageTextField)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            messageTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            messageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            messageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            messageTextField.heightAnchor.constraint(equalToConstant: 300),

            saveButton.topAnchor.constraint(equalTo: messageTextField.bottomAnchor, constant: 20),
            saveButton.leadingAnchor.constraint(equalTo: messageTextField.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: messageTextField.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
