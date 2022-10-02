//
//  LoginVC.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 30.09.2022.
//

import UIKit

class LoginVC: UIViewController {

    let nameOfApplication = ABTitleLabel(textAlignment: .center, fontSize: 30)
    let emailTextField = ABTextField()
    let passwordTextField = ABTextField()
    let loginPressed = ABButton(backgroundColor: .systemGreen, title: "Log In")
    let registerPressed = ABButton(backgroundColor: .systemBlue, title: "Register")

    let notesListNC = UINavigationController(rootViewController: NotesListVC())

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        notesListNC.modalPresentationStyle = .fullScreen

        configure()
    }

    @objc func logIn() {
         FirebaseManager.shared.logIn(email: emailTextField, password: passwordTextField, completion: { error in
             if let err = error {
                 self.presentABAlertOnMainThread(title: "Something went wrong", message: err.localizedDescription, buttonTitle: "Ок")
             } else {
                 self.present(self.notesListNC, animated: true)
             }
        })
    }

    @objc func registration() {
        FirebaseManager.shared.registration(email: emailTextField, password: passwordTextField, completion: { error in
            if let err = error {
                self.presentABAlertOnMainThread(title: "Something went wrong", message: err.localizedDescription, buttonTitle: "Ок")
            } else {
                self.present(self.notesListNC, animated: true)
            }
       })
    }

    private func configure() {
        view.addSubview(nameOfApplication)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginPressed)
        view.addSubview(registerPressed)

        nameOfApplication.text = "Список задач"
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"

        passwordTextField.isSecureTextEntry = true

        let padding: CGFloat = 50
        let height: CGFloat = 30

        loginPressed.addTarget(self, action: #selector(logIn), for: .touchUpInside)
        registerPressed.addTarget(self, action: #selector(registration), for: .touchUpInside)

        NSLayoutConstraint.activate([
            nameOfApplication.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height / 5),
            nameOfApplication.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            nameOfApplication.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            nameOfApplication.heightAnchor.constraint(equalToConstant: height),

            emailTextField.topAnchor.constraint(equalTo: nameOfApplication.topAnchor, constant: 80),
            emailTextField.leadingAnchor.constraint(equalTo: nameOfApplication.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: nameOfApplication.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: height),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: height),

            loginPressed.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: padding),
            loginPressed.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            loginPressed.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            loginPressed.heightAnchor.constraint(equalToConstant: 44),

            registerPressed.topAnchor.constraint(equalTo: loginPressed.bottomAnchor, constant: 20),
            registerPressed.leadingAnchor.constraint(equalTo: loginPressed.leadingAnchor),
            registerPressed.trailingAnchor.constraint(equalTo: loginPressed.trailingAnchor),
            registerPressed.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
