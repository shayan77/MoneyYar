//
//  CheckBox.swift
//  MoneyYar
//
//  Created by Shayan Mehranpoor on 10/16/18.
//  Copyright © 2018 Shayan Mehranpoor. All rights reserved.
//

import Foundation
import UIKit
import M13Checkbox

extension M13Checkbox {
    func custom() {
        self.tintColor = UIColor(red: 41/255, green: 167/255, blue: 68/255, alpha: 1.0)
        self.stateChangeAnimation = .bounce(.fill)
    }
}
