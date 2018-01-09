//
//  Float+toString.swift
//  Player
//
//  Created by Sitora on 10.01.18.
//  Copyright © 2018 Sitora. All rights reserved.
//

import Foundation
extension Formatter {

    static let number: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .halfEven
        formatter.numberStyle = .decimal
        return formatter
    }()

}

extension Float {
    func toString() -> String {
        return Formatter.number.string(for: self) ?? ""
    }
}
