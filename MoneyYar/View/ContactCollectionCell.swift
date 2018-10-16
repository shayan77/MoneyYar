//
//  ContactCollectionCell.swift
//  MoneyYar
//
//  Created by Shayan Mehranpoor on 10/16/18.
//  Copyright © 2018 Shayan Mehranpoor. All rights reserved.
//

import UIKit

class ContactCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.userAvatar.roundView()
    }
    
    func updateContactList(contact: Contact) {
        self.nameLbl.text = contact.name ?? "-"
    }
}
