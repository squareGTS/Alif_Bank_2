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

    var noteTextField = ABTextField()
    var messageTextField = ABTextField()
    var editButton = ABButton(backgroundColor: .systemRed, title: "Edit")
    var sendMessageButton = ABButton(backgroundColor: .systemBlue, title: "Send Message")
    var senderLabel = ABLabel(textAlignment: .center, fontSize: 16, numberOfLines: 1)

    var tableView = UITableView()
    var id: String!
    var note: Note!
    var messages: [Message] = []

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        editButton.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
        sendMessageButton.addTarget(self, action: #selector(sendMessageButtonPressed), for: .touchUpInside)

        configure()
        configureTableView()
        loadNotes()
        loadMessages()
    }

    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reusedID)
    }

    func loadNotes() {

        db.collection("notes")
            .order(by: "date")
            .addSnapshotListener { (querySnapshot, error) in

                if let e = error {
                    print("There was an issue retrieving data from Firestore. \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {

                        for doc in snapshotDocuments {
                            if doc.documentID == self.id {
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

    func loadMessages() {

        db.collection("messages")
            .order(by: "date")
            .addSnapshotListener { (querySnapshot, error) in

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
    @objc func sendMessageButtonPressed() {

        if let messageBody = messageTextField.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection("messages").addDocument(data: [
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

    @objc func editButtonPressed() {

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

                    DispatchQueue.main.async {
                        self.noteTextField.text = ""
                    }
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

        NSLayoutConstraint.activate([
            editButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            editButton.widthAnchor.constraint(equalToConstant: 150),
            editButton.heightAnchor.constraint(equalToConstant: 20),

            senderLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            senderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            senderLabel.widthAnchor.constraint(equalToConstant: 76),
            senderLabel.heightAnchor.constraint(equalToConstant: 20),

            noteTextField.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 20),
            noteTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noteTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            noteTextField.heightAnchor.constraint(equalToConstant: 100),

            tableView.topAnchor.constraint(equalTo: noteTextField.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            tableView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor, constant: -10),

            messageTextField.bottomAnchor.constraint(equalTo: sendMessageButton.topAnchor, constant: -10),
            messageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            messageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            messageTextField.heightAnchor.constraint(equalToConstant: 30),

            sendMessageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            sendMessageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            sendMessageButton.heightAnchor.constraint(equalToConstant: 40),
            sendMessageButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
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
        return 56
    }
}
