//
//  Date+Ext.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 02.10.2022.
//

import Foundation

extension Date {

    func convertToFullDateFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a, d MMM, yyyy"
        return dateFormatter.string(from: self)
    }
}
