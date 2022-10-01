//
//  NotesListVC.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 30.09.2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NotesListVC: UIViewController {

    var logout = ABButton(frame: .zero)
    let db = Firestore.firestore()
    var notes: [Note] = []

    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: "rectangle.portrait.and.arrow.forward"), target: self, action: #selector(signOut))

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: "plus"), target: self, action: #selector(createNote))

        configure()
        configureTableView()
        loadNotes()
    }

    func configureTableView() {
        tableView = UITableView(frame: view.bounds)

        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(NoteCell.self, forCellReuseIdentifier: NoteCell.reusedID)
    }

    func loadNotes() {

        db.collection("notes")
            .order(by: "date")
            .addSnapshotListener { (querySnapshot, error) in

            self.notes = []

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
                            let newMessage = Note(sender: messageSender, body: messageBody, id: doc.documentID)
                            self.notes.append(newMessage)

                            DispatchQueue.main.async {
                                   self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.notes.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                            }
                        }
                    }
                }
            }
        }
    }

    private func configure() {
        view.addSubview(logout)

        logout.addTarget(self, action: #selector(signOut), for: .touchUpInside)

        NSLayoutConstraint.activate([
            logout.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            logout.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logout.heightAnchor.constraint(equalToConstant: 20),
            logout.widthAnchor.constraint(equalToConstant:20),
        ])
    }

    @objc func createNote() {

        let noteVC = NoteVC()
        noteVC.modalPresentationStyle = .fullScreen

        self.present(UINavigationController(rootViewController: noteVC), animated: true)
    }

    @objc func signOut() {
        FirebaseManager.shared.signOut() ? dismiss(animated: true) : print("Error signing out")
    }
}

extension NotesListVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let message = notes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.reusedID, for: indexPath) as! NoteCell
        cell.label.text = message.body
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let destVC = DetailNoteVC()
        destVC.id = notes[indexPath.row].id
        destVC.note = notes[indexPath.row]

        let navController = UINavigationController(rootViewController: destVC)
        present(navController, animated: true)
    }

    private func handleMoveToTrash(id: String) {

        db.collection("notes").document(id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                self.loadNotes()
                print("Document successfully removed!")
            }
        }
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                        title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            self.handleMoveToTrash(id: self.notes[indexPath.row].id)
                                            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}
