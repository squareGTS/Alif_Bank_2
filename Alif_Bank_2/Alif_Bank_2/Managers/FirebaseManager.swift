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

    @objc func logIn(email: UITextField, password: UITextField) -> UIViewController {
        var vc = UIViewController()
        vc.modalPresentationStyle = .fullScreen

        if let email = email.text, let password = password.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                } else {
                    vc = NotesListVC()
                }
            }
        }
        return vc
    }

    @objc func registration(email: UITextField, password: UITextField) -> UIViewController {
        var vc = UIViewController()
        vc.modalPresentationStyle = .fullScreen

        if let email = email.text, let password = password.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                } else {
                    vc = NotesListVC()
                }
            }
        }
        return vc
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
}
