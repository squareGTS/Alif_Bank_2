//
//  DetailNoteVC.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 01.10.2022.
//

import UIKit

class DetailNoteVC: UIViewController {

    var pickerDataSource = ["New", "In progress", "Ready for review", "Complete"]

    let senderButton = ABButton(backgroundColor: .systemGreen, title: "")
    let saveButton = ABButton(backgroundColor: .systemRed, title: "Save")
    let statusLabel = ABLabel()
    let noteTextField = ABTextField()
    let titleComment = ABLabel()
    let dateLabel = ABLabel()
    let messageTextField = ABTextField()
    let sendMessageButton = ABButton(backgroundColor: .systemBlue, title: "Send Message")
    let pickStatus = UIPickerView()

    var tableView = UITableView()
    var pickerIndex = Int()
    var notes: [Note] = []
    var indPath = Int()
    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Detail Notes"

        titleComment.text = "Leave a comment bellow"
        dateLabel.text = notes[indPath].date

        senderButton.addTarget(self, action: #selector(senderPressed), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        sendMessageButton.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)

        configure()
        configurePicker()
        configureTableView()
        loadNotes()
        loadingMessages()
        getStatus()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotes()
    }

    func configurePicker() {
        pickStatus.translatesAutoresizingMaskIntoConstraints = false
        pickStatus.dataSource = self
        pickStatus.delegate = self
    }

    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reusedID)
    }

    func getStatus() {
        changeBackground(row: pickerDataSource.firstIndex(of: notes[indPath].status) ?? 0)
        pickStatus.selectRow(pickerDataSource.firstIndex(of: notes[indPath].status) ?? 0, inComponent: 0, animated: true)
    }

    func changeBackground(row: Int) {
        switch row {
        case 0: self.view.backgroundColor = .systemBackground
        case 1: self.view.backgroundColor = .systemRed
        case 2: self.view.backgroundColor = .systemGray3
        case 3: self.view.backgroundColor = .systemGreen
        default:
            break
        }
    }

    func loadNotes() {
        FirebaseManager.shared.loadData(collectionName: "notes") { querySnapshot, error in

            if let err = error {
                self.presentABAlertOnMainThread(title: "Something went wrong",
                                                message: err.localizedDescription,
                                                buttonTitle: "Ok")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {

                    for doc in snapshotDocuments {
                        if doc.documentID == self.notes[self.indPath].id {
                            let data = doc.data()

                            if let sender = data["sender"] as? String,
                               let body = data["body"] as? String,
                               let currentStatus = data["status"] as? String,
                               let date = data["date"] as? String {

                                let newMessage = Note(id: doc.documentID,
                                                      date: date,
                                                      sender: sender,
                                                      body: body,
                                                      status: currentStatus)
                                self.notes[self.indPath] = newMessage
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

            if let err = error {
                self.presentABAlertOnMainThread(title: "Something went wrong", message: err.localizedDescription, buttonTitle: "Ok")
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

    @objc func senderPressed() {
        let taskSettingsVC = TaskSettingsVC()
        taskSettingsVC.notes = notes
        taskSettingsVC.currentPerforemer = senderButton.titleLabel?.text?.description ?? ""
        taskSettingsVC.currentIndex = indPath

        let taskSettingsNC = UINavigationController(rootViewController: taskSettingsVC)
        present(taskSettingsNC, animated: true)
    }

    @objc func sendPressed() {
        FirebaseManager.shared.saveData(message: messageTextField,
                                        collection: "messages",
                                        curentStatus: "",
                                        completion: { error in
            if let err = error {
                self.presentABAlertOnMainThread(title: "Something went wrong",
                                                message: err.localizedDescription,
                                                buttonTitle: "Ок")
            } else {
                DispatchQueue.main.async {
                    self.messageTextField.text = ""
                }
            }
        })
        DispatchQueue.main.async {
            self.messageTextField.text = ""
        }
    }

    @objc func savePressed() {
        FirebaseManager.shared.editData(message: noteTextField.text,
                                        sender: notes[indPath].sender,
                                        date: Date().convertToFullDateFormat(),
                                        collectionName: "notes",
                                        id: notes[indPath].id,
                                        curentStaatus: pickerDataSource[pickerIndex]) { error in
            if let err = error {
                self.presentABAlertOnMainThread(title: "Something went wrong",
                                                message: err.localizedDescription,
                                                buttonTitle: "Ок")
            } else {
                self.presentABAlertOnMainThread(title: "Your Changes:",
                                                message: "Saved",
                                                buttonTitle: "Ок")
            }
        }
    }

    private func configure() {
        view.addSubview(senderButton)
        view.addSubview(saveButton)
        view.addSubview(pickStatus)
        view.addSubview(dateLabel)
        view.addSubview(noteTextField)
        view.addSubview(titleComment)
        view.addSubview(tableView)
        view.addSubview(messageTextField)
        view.addSubview(sendMessageButton)

        senderButton.setTitle(notes[indPath].sender, for: .normal)
        noteTextField.text = notes[indPath].body

        let padding: CGFloat = 8

        NSLayoutConstraint.activate([
            senderButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            senderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            senderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            senderButton.heightAnchor.constraint(equalToConstant: 30),

            pickStatus.topAnchor.constraint(equalTo: senderButton.bottomAnchor, constant: padding),
            pickStatus.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            pickStatus.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) - padding),
            pickStatus.heightAnchor.constraint(equalToConstant: 40),

            saveButton.centerYAnchor.constraint(equalTo: pickStatus.centerYAnchor),
            saveButton.leadingAnchor.constraint(equalTo: pickStatus.trailingAnchor, constant: padding),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            saveButton.heightAnchor.constraint(equalToConstant: 30),

            dateLabel.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            dateLabel.heightAnchor.constraint(equalToConstant: 20),

            noteTextField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            noteTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            noteTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            noteTextField.heightAnchor.constraint(equalToConstant: 30),

            titleComment.topAnchor.constraint(equalTo: noteTextField.bottomAnchor, constant: 25),
            titleComment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleComment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            titleComment.heightAnchor.constraint(equalToConstant: 20),

            tableView.topAnchor.constraint(equalTo: titleComment.bottomAnchor, constant: padding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            tableView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor, constant: -padding),

            messageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            messageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            messageTextField.bottomAnchor.constraint(equalTo: sendMessageButton.topAnchor, constant: -padding),
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reusedID, for: indexPath) as! MessageCell
        cell.senderLabel.text = messages[indexPath.row].sender
        cell.messageLabel.text = messages[indexPath.row].body
        return cell
    }
}

extension DetailNoteVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerIndex = row
        changeBackground(row: row)
    }
}
