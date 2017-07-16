//
//  ContactsViewController.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 12/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import UIKit
import Contacts
import Firebase

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var contacts: [CNContact] = []
    var matchedContacts: [String: String] = [:]
    var matchedContactsInfo: [String: CNContact] = [:]
    var matchedContactsArray = [String]()
    public var userNumber: String?
    public var group: Group?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setMenuText()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tryGetUsersApproval()
    }
    
    func setMenuText(){
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = NSLocalizedString("menuAddUser", comment: "contact title text")
    }
    func tryGetUsersApproval(){
        CNContactStore().requestAccess(for: .contacts){ (isGranted, error) in
            if isGranted{
                self.getUsersContactInfo()
                self.getPhoneNumbersFromDatabase()
            }else{
                self.showPermissionErrorDialog()
            }
        }
    }
    func showPermissionErrorDialog(){
        let refreshAlert = UIAlertController(title: NSLocalizedString("addUserErrorDialogTitle", comment: "alert title"), message: NSLocalizedString("addUserErrorDialogMsg", comment: "alert msg"), preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("addUserErrorDialogOk", comment: "alert ok"), style: .default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popViewController(animated: true)
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    func getUsersContactInfo(){
        contacts = {
            let contactStore = CNContactStore()
            let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                CNContactPhoneNumbersKey] as [Any]
            
            var allContainers: [CNContainer] = []
            do {
                allContainers = try contactStore.containers(matching: nil)
            } catch {
                print("Error fetching containers")
            }
            var results: [CNContact] = []
            for container in allContainers {
                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
                do {
                    let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                    results.append(contentsOf: containerResults)
                } catch {
                    print("Error fetching results for container")
                }
            }
            return results
        }()
    }
    
    func getPhoneNumbersFromDatabase(){
        let ref = Database.database().reference().child("numbers")
        ref.keepSynced(true)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let dataValue = snapshot.value as? NSDictionary
            for (key, value) in dataValue!{
                if key as? String != self.userNumber{
                    if !self.checkIfGroupAlreadyContainsUser(uID: value as! String){
                        if self.numberExistsOnDatabase(number: key as! String){
                            self.matchedContacts[key as! String] = value as? String
                            self.matchedContactsArray.append((key as? String)!)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            self.contacts = []
        })
    }
    func checkIfGroupAlreadyContainsUser(uID: String) -> Bool{
        for (_, val) in (group?.users)!{
            if val == uID{
                return true
            }
        }
        return false
    }
    func numberExistsOnDatabase(number: String) -> Bool{
        for contact in contacts{
            var contactNumber =  (contact.phoneNumbers[0].value).value(forKey: "digits") as! String
            if contactNumber[contactNumber.characters.startIndex] == "+" {
                let range = contactNumber.characters.startIndex ..< contactNumber.characters.index(contactNumber.startIndex, offsetBy: 3)
                contactNumber.removeSubrange(range)
            }
            if contactNumber == number{
                matchedContactsInfo[number] = contact
                return true
            }
        }
        return false
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactTableViewCell
        if matchedContactsArray.count > 0{
            cell.txtName.text = matchedContactsInfo[self.matchedContactsArray[indexPath.row]]?.givenName
            if let firstLetter = matchedContactsInfo[self.matchedContactsArray[indexPath.row]]?.givenName.characters.first{
                cell.txtLetter.text = String(firstLetter).uppercased()
            }
            cell.txtNumber.text = matchedContactsArray[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return matchedContactsArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlertDialog(index: indexPath.row)
    }
    
    func showAlertDialog(index: Int){
        let refreshAlert = UIAlertController(title: NSLocalizedString("addUserDialogTitle", comment: "alert title"), message: NSLocalizedString("addUserDialogMsg", comment: "alert msg"), preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("addUserDialogBtnOk", comment: "alert ok"), style: .default, handler: { (action: UIAlertAction!) in
            self.putUserInGroup(index: index)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("addUserDialogBtnCancel", comment: "alert cancel"), style: .cancel, handler: { (action: UIAlertAction!) in
            self.tableView.reloadData()
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func putUserInGroup(index: Int){
        group?.setUsers(uID: matchedContacts[matchedContactsArray[index]]!)
        DatabaseFunctions.updateGroup(group: group!)
        updateSelectedUser(index: index)
        navigationController?.popViewController(animated: true)
    }
    func updateSelectedUser(index: Int){
        let ref = Database.database().reference().child("users").child(matchedContacts[matchedContactsArray[index]]!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let email = value?["email"] as? String ?? ""
            let name = value?["name"] as? String ?? ""
            let telephone = value?["telephone"] as? String ?? ""
            let user = User.init(name: name, email: email, telephone: telephone)
            var groups: [String: String] = [:]
            var cont : Int = 0
            if snapshot.childSnapshot(forPath: "groups").childrenCount > 0{
                let childSnapshot = snapshot.childSnapshot(forPath: "groups")
                for subValue in childSnapshot.children{
                    let subSnap = subValue as! DataSnapshot
                    groups[String(cont)] = subSnap.value as? String
                    cont = cont + 1
                }
            }
            user.addGroup(group: (self.group?.id)!)
            DatabaseFunctions.updateOtherUser(user: user, uID: self.matchedContacts[self.matchedContactsArray[index]]!)
        })
        
    }
}
