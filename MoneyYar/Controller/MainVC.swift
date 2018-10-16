//
//  ViewController.swift
//  MoneyYar
//
//  Created by Shayan Mehranpoor on 10/15/18.
//  Copyright © 2018 Shayan Mehranpoor. All rights reserved.
//

import UIKit
import Contacts
import RxCocoa
import RxSwift

class MainVC: UIViewController {
    
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var contactCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    var contacts = [Contact]()
    var filteredContacts = [Contact]()
    var collectionContacts = [Contact]()
    var isSearching = false
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        fetchAllContacts {
            self.contactTableView.reloadData()
        }
        
        searchTextField
            .rx.text
            .orEmpty
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [unowned self] query in
                self.filteredContacts = self.contacts.filter({(contact : Contact) -> Bool in
                    return ((contact.name?.lowercased().contains(query.lowercased()))! || (contact.mobile?.lowercased().contains(query.lowercased()))!)
                })
                self.contactTableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    func initUI() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "IRANYekanMobile(FaNum)", size: 20)!]
        
        contactTableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 16))
        contactTableView.delegate = self
        contactTableView.dataSource = self
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        contactCollectionView.delegate = self
        contactCollectionView.dataSource = self
        
        searchView.roundView()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text == "" {
            isSearching = false
            self.view.endEditing(true)
            contactTableView.reloadData()
        } else {
            isSearching = true
        }
    }
    
    func fetchAllContacts(completion: @escaping () -> ()) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts, completionHandler: {
            granted, error in
            
            guard granted else {
                let alert = UIAlertController(title: "Can't access contact", message: "Please go to Settings -> MyApp to enable contact permission", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as [Any]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
            
            do {
                try store.enumerateContacts(with: request) {
                    (contact, cursor) -> Void in
                    let contact = Contact(name: CNContactFormatter.string(from: contact, style: .fullName) ?? "-", mobile: contact.phoneNumbers[0].value.value(forKey: "digits") as! String, isSelected: false)
                    self.contacts.append(contact)
                    completion()
                }
            } catch let error {
                print("Fetch contact error: \(error)")
            }
        })
    }
}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }, completion: { finished in
            UIView.animate(withDuration: 0.1, animations: {
                cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
            })
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredContacts.count
        } else {
            return contacts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as? ContactCell {
            
            if isSearching {
                let contact = self.filteredContacts[indexPath.row]
                cell.updateContactList(contact: contact)
                if self.filteredContacts[indexPath.row].isSelected ?? false {
                    cell.checkBox.checkState = .checked
                } else {
                    cell.checkBox.checkState = .unchecked
                }
                return cell
            } else {
                let contact = self.contacts[indexPath.row]
                cell.updateContactList(contact: contact)
                if self.contacts[indexPath.row].isSelected ?? false {
                    cell.checkBox.checkState = .checked
                } else {
                    cell.checkBox.checkState = .unchecked
                }
                return cell
            }
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ContactCell {
            if isSearching {
                self.filteredContacts[indexPath.row].isSelected = true
                self.collectionContacts.append(self.filteredContacts[indexPath.row])
                if let index = contacts.index(where: { $0.mobile == self.filteredContacts[indexPath.row].mobile }) {
                    contacts[index].isSelected = true
                }
            } else {
                self.contacts[indexPath.row].isSelected = true
                self.collectionContacts.append(self.contacts[indexPath.row])
            }
            cell.checkBox.checkState = .checked
            reloadCollection()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ContactCell {
            if isSearching {
                self.filteredContacts[indexPath.row].isSelected = false
                if let index = collectionContacts.index(where: { $0.mobile == self.filteredContacts[indexPath.row].mobile }) {
                    collectionContacts.remove(at: index)
                }
                if let index = contacts.index(where: { $0.mobile == self.filteredContacts[indexPath.row].mobile }) {
                    contacts[index].isSelected = false
                }
            } else {
                self.contacts[indexPath.row].isSelected = false
                if let index = collectionContacts.index(where: { $0.mobile == self.contacts[indexPath.row].mobile }) {
                    collectionContacts.remove(at: index)
                }
            }
            cell.checkBox.checkState = .unchecked
            reloadCollection()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionContacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactCollectionCell", for: indexPath) as? ContactCollectionCell {
            
            let contact = collectionContacts[indexPath.row]
            cell.updateContactList(contact: contact)
            
            return cell
            
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let index = contacts.index(where: { $0.mobile == self.collectionContacts[indexPath.row].mobile }) {
            self.contacts[index].isSelected = false
            collectionContacts.remove(at: indexPath.row)
            reloadCollection()
            self.contactTableView.reloadData()
        }
    }
    
    func reloadCollection() {
        if collectionContacts.isEmpty {
            self.collectionViewHeight.constant = 0
            self.contactCollectionView.reloadData()
        } else {
            self.collectionViewHeight.constant = 70
            self.contactCollectionView.reloadData()
        }
    }
}

