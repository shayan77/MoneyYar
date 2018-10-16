//
//  Contact.swift
//  MoneyYar
//
//  Created by Shayan Mehranpoor on 10/16/18.
//  Copyright © 2018 Shayan Mehranpoor. All rights reserved.
//

import Foundation

struct Contact {
    var name: String?
    var mobile: String?
    var isSelected: Bool?
    
    init(name: String, mobile: String, isSelected: Bool) {
        self.name = name
        self.mobile = mobile
        self.isSelected = isSelected
    }
}
