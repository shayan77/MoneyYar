//
//  UIImageView.swift
//  MoneyYar
//
//  Created by Shayan Mehranpoor on 10/16/18.
//  Copyright © 2018 Shayan Mehranpoor. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func roundView() {
        self.layer.cornerRadius = self.layer.frame.height / 2
    }
}
