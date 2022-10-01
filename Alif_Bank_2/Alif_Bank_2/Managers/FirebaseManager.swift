//
//  FirebaseManager.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 01.10.2022.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager {

    static let shared = FirebaseManager()
    let db = Firestore.firestore()

    @objc func logIn(email: UITextField, password: UITextField, completion: @escaping () ->()) {

        if let email = email.text, let password = password.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                } else {
                    completion()
                }
            }
        }
    }

    @objc func registration(email: UITextField, password: UITextField, completion: @escaping () ->()) {

        if let email = email.text, let password = password.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                } else {
                    completion()
                }
            }
        }
    }

    @objc func signOut() -> Bool {
        var status: Bool

        do {
            try Auth.auth().signOut()
            status = true
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            status = false
        }
        return status
    }

    @objc func saveData(message: UITextField, collection: String) {

        if let messageBody = message.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(collection).addDocument(data: [
                "sender": messageSender,
                "body": messageBody,
                "date": Date().timeIntervalSince1970,
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                } else {
                    print("Successfully saved data.")
                }
            }
        }
    }

    func deleteData(id: String, completion: @escaping () -> ()) {

        db.collection("notes").document(id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                completion()
                print("Document successfully removed!")
            }
        }
    }

    func loadData(collectionName: String, completion: @escaping (QuerySnapshot?, Error?) -> ()) {

        db.collection(collectionName)
            .order(by: "date")
            .addSnapshotListener { (querySnapshot, error) in

                completion(querySnapshot, error)
            }
    }


}
