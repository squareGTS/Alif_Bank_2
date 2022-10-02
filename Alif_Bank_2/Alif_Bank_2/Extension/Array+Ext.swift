//
//  Array.swift
//  Alif_Bank_2
//
//  Created by Maxim Bekmetov on 02.10.2022.
//

import Foundation

extension Array where Element: Hashable {
    func uniqued() -> Array {
        var buffer = Array()

        forEach {
            if !buffer.contains($0) {
                buffer.append($0)
            }
        }
        return buffer
    }
}
