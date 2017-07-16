//
//  HideKeyboard.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 6/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
