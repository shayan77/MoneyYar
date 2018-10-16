//
//  ContactCell.swift
//  MoneyYar
//
//  Created by Shayan Mehranpoor on 10/16/18.
//  Copyright © 2018 Shayan Mehranpoor. All rights reserved.
//

import UIKit
import M13Checkbox

class ContactCell: UITableViewCell {
    
    @IBOutlet weak var checkBox: M13Checkbox!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var mobileLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userAvatar.roundView()
        checkBox.custom()
    }
    
    func updateContactList(contact: Contact) {
        self.fullnameLbl.text = contact.name ?? "-"
        self.mobileLbl.text = contact.mobile ?? "-"
    }
}
