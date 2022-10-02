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

    func logIn(email: UITextField, password: UITextField, completion: @escaping (Error?)->()) {
        if let email = email.text, let password = password.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                completion(error)
            }
        }
    }

    func registration(email: UITextField, password: UITextField, completion: @escaping (Error?)->()) {
        if let email = email.text, let password = password.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                completion(error)
            }
        }
    }

    func signOut() -> Bool {
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

    func saveData(id: String, message: UITextField, collection: String, curentStatus: String, completion: @escaping (Error?)->()) {
        if let messageBody = message.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(collection).addDocument(data: [
                "id": id,
                "date": Date().convertToFullDateFormat(),
                "sender": messageSender,
                "body": messageBody,
                "status": curentStatus,
            ]) { (error) in
                completion(error)
            }
        }
    }

    @objc func editData(message: String?, sender: String, date: String, collectionName: String, id: String, curentStaatus: String, completion: @escaping (Error?)->()) {

        if let messageBody = message {
            db.collection(collectionName).document(id).setData([
                "date": date,
                "sender": sender,
                "body": messageBody,
                "status": curentStaatus
            ]) { error in
                completion(error)
            }
        }
    }

    func deleteData(collectionName: String, id: String, completion: @escaping (Error?) -> ()) {
        db.collection(collectionName).document(id).delete() { error in
            completion(error)
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
