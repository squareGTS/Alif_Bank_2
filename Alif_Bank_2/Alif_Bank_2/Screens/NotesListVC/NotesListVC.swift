//
//  NotesListVC.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 30.09.2022.
//

import UIKit

class NotesListVC: UIViewController {

    let logout = ABButton(frame: .zero)
    var notes: [Note] = []

    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: "rectangle.portrait.and.arrow.forward"), target: self, action: #selector(signOut))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: "plus"), target: self, action: #selector(createNote))

        configure()
        configureTableView()
        loadingNotes()
    }

    func configureTableView() {
        tableView = UITableView(frame: view.bounds)

        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(NoteCell.self, forCellReuseIdentifier: NoteCell.reusedID)
    }

    func loadingNotes() {
        FirebaseManager.shared.loadData(collectionName: "notes") { querySnapshot, error in
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

                        if let sender = data["sender"] as? String,
                           let body = data["body"] as? String,
                           let date = data["date"] as? String,
                           let currentStatus = data["status"] as? String {

                            let newMessage = Note(id: doc.documentID,
                                                  date: date,
                                                  sender: sender,
                                                  body: body,
                                                  status: currentStatus)
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
        self.present(UINavigationController(rootViewController: NoteVC()), animated: true)
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
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.reusedID, for: indexPath) as! NoteCell
        cell.noteLabel.text = notes[indexPath.row].body
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailNoteVC = DetailNoteVC()
        detailNoteVC.notes = notes
        detailNoteVC.indPath = indexPath.row

        let detailNoteNC = UINavigationController(rootViewController: detailNoteVC)
        present(detailNoteNC, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive,
                                        title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }

            FirebaseManager.shared.deleteData(collectionName: "notes", id: self.notes[indexPath.row].id) { error in
                if let err = error {
                    self.presentABAlertOnMainThread(title: "Something went wrong", message: err.localizedDescription, buttonTitle: "Ок")
                } else {
                    self.loadingNotes()
                    completionHandler(true)
                }
            }
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}
