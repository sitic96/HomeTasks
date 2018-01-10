//
//  UIViewController+showAlert.swift
//  Player
//
//  Created by Sitora on 10.01.18.
//  Copyright © 2018 Sitora. All rights reserved.
//

import UIKit
extension UIViewController {
    func showAlert(title: String, text: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
