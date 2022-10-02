//
//  UIVIewController+Ext.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 02.10.2022.
//

import UIKit

extension UIViewController {

    func presentABAlertOnMainThread(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertVC = ABAlertVC(title: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            self.present(alertVC, animated: true)
        }
    }
}
