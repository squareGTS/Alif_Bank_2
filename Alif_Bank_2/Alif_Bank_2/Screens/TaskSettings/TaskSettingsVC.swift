//
//  TaskSettingsVC.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 01.10.2022.
//

import UIKit

class TaskSettingsVC: UIViewController {

    let myDatePicker = UIDatePicker()
    var chosenPerformer = ABLabel()
    let saveButton = ABButton(backgroundColor: .systemBlue, title: "Save")

    var currentPerforemer = String()
    let tableView = UITableView()
    var currentSender = String()

    var notes: [Note] = []
    var filterd: [String] = []
    var currentIndex = Int()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        saveButton.addTarget(self, action: #selector(changePerformerSettings), for: .touchUpInside)
        chosenPerformer.text = currentPerforemer

        configure()
        filterNotes()
        configureTableView()
        configurePicker()
    }

    func filterNotes() {
        filterd = notes.map { $0.sender }.uniqued()
    }
    
    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reusedID)
    }

    func configurePicker() {
        myDatePicker.translatesAutoresizingMaskIntoConstraints = false

        myDatePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        let currentDate = Date()
        myDatePicker.date = currentDate as Date
    }

    @objc func changePerformerSettings() {
        FirebaseManager.shared.editData(message: notes[currentIndex].body,
                                        sender: currentSender,
                                        date: myDatePicker.date.convertToFullDateFormat(),
                                        collectionName: "notes",
                                        id: notes[currentIndex].id,
                                        curentStaatus: notes[currentIndex].status) { error in
            if let err = error {
                self.presentABAlertOnMainThread(title: "Something went wrong", message: err.localizedDescription, buttonTitle: "Ок")
            } else {
                self.presentABAlertOnMainThread(title: "Your Changes", message: "Saved", buttonTitle: "Ок")
            }
        }
    }

    func configure() {
        view.addSubview(chosenPerformer)
        view.addSubview(myDatePicker)
        view.addSubview(tableView)
        view.addSubview(saveButton)

        let padding: CGFloat = 6

        NSLayoutConstraint.activate([
            chosenPerformer.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            chosenPerformer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            chosenPerformer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            chosenPerformer.heightAnchor.constraint(equalToConstant: 30),

            myDatePicker.topAnchor.constraint(equalTo: chosenPerformer.topAnchor, constant: 40),
            myDatePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            myDatePicker.heightAnchor.constraint(equalToConstant: 50),

            tableView.topAnchor.constraint(equalTo: myDatePicker.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            tableView.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: -30),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }
}

extension TaskSettingsVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterd.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reusedID, for: indexPath) as! UserCell
        cell.userLabel.text = filterd[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenPerformer.text = filterd[indexPath.row]
        currentSender = filterd[indexPath.row]
    }
}

