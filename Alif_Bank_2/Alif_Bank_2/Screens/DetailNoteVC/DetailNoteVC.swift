//
//  DetailNoteVC.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 01.10.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DetailNoteVC: UIViewController {

    let noteTextField = ABTextField()
    let messageTextField = ABTextField()
    let editButton = ABButton(backgroundColor: .systemRed, title: "Edit")
    let sendMessageButton = ABButton(backgroundColor: .systemBlue, title: "Send Message")
    let senderLabel = ABLabel(textAlignment: .center, fontSize: 14, numberOfLines: 2)

    var tableView = UITableView()
    var note: Note!
    var messages: [Message] = []

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Detail Notes"

        editButton.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
        sendMessageButton.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)

        configure()
        configureTableView()
        loadNotes()
        loadingMessages()
    }

    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reusedID)
    }

    func loadNotes() {
        FirebaseManager.shared.loadData(collectionName: "notes") { querySnapshot, error in

            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {

                    for doc in snapshotDocuments {
                        if doc.documentID == self.note.id {
                            let data = doc.data()

                            if let messageSender = data["sender"] as? String, let messageBody = data["body"] as? String {
                                let newMessage = Note(sender: messageSender, body: messageBody, id: doc.documentID)
                                self.note = newMessage
                            }
                        }
                    }
                }
            }
        }
    }

    func loadingMessages() {
        FirebaseManager.shared.loadData(collectionName: "messages") { querySnapshot, error in
            self.messages = []

            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {

                    if snapshotDocuments.isEmpty {
                        self.tableView.reloadData()
                    }

                    for doc in snapshotDocuments {
                        let data = doc.data()

                        if let messageSender = data["sender"] as? String, let messageBody = data["body"] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)

                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                            }
                        }
                    }
                }
            }
        }
    }

    @objc func sendPressed() {
        FirebaseManager.shared.saveData(message: messageTextField, collection: "messages")

        DispatchQueue.main.async {
            self.messageTextField.text = ""
        }
    }

    @objc func editPressed() {

        if let messageBody = noteTextField.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection("notes").addDocument(data: [
                "sender": messageSender,
                "body": messageBody,
                "date": Date().timeIntervalSince1970,
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("Successfully saved data.")

                    //                    DispatchQueue.main.async {
                    //                        self.noteTextField.text = ""
                    //                    }
                }
            }
        }
    }

    private func configure() {
        view.addSubview(senderLabel)
        view.addSubview(editButton)
        view.addSubview(noteTextField)
        view.addSubview(tableView)
        view.addSubview(messageTextField)
        view.addSubview(sendMessageButton)

        senderLabel.text = note.sender
        noteTextField.text = note.body

        let padding: CGFloat = 6

        NSLayoutConstraint.activate([
            editButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            editButton.heightAnchor.constraint(equalToConstant: 30),
            editButton.widthAnchor.constraint(equalToConstant: 80),

            senderLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            senderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            senderLabel.heightAnchor.constraint(equalToConstant: 20),
            senderLabel.widthAnchor.constraint(equalToConstant: view.frame.width / 2),

            noteTextField.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 20),
            noteTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            noteTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            noteTextField.heightAnchor.constraint(equalToConstant: 30),

            tableView.topAnchor.constraint(equalTo: noteTextField.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            tableView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor, constant: -10),

            messageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            messageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            messageTextField.bottomAnchor.constraint(equalTo: sendMessageButton.topAnchor, constant: -10),
            messageTextField.heightAnchor.constraint(equalToConstant: 30),

            sendMessageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            sendMessageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            sendMessageButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            sendMessageButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

extension DetailNoteVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reusedID, for: indexPath) as! MessageCell
        cell.senderLabel.text = messages[indexPath.row].sender
        cell.messageLabel.text = messages[indexPath.row].body
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
