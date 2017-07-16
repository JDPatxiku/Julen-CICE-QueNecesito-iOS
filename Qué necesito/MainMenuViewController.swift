//
//  MainMenuViewController.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 5/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class MainMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtNumber: UILabel!
    @IBOutlet weak var txtEditAccount: UILabel!
    @IBOutlet weak var txtCreateNewList: UILabel!
    @IBOutlet weak var txtSignOut: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var user: User?
    private var groups: [String: Group]?
    private var groupsID = [String]()
    
    @IBAction func btnMenuAction(_ sender: Any) {
        if leadingConstraint.constant != 0{
            leadingConstraint.constant = 0
            showMenuAnimation()
        }else{
            leadingConstraint.constant = -295
            showMenuAnimation()
        }
    }
    @IBAction func btnSignOutAction(_ sender: Any) {
        try! Auth.auth().signOut()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "unwindToMainViewController", sender: self)
        }
    }
    @IBAction func btnEditAccountAction(_ sender: Any) {
        
    }
    @IBAction func btnCreateNewListAction(_ sender: Any) {
        
    }
    @IBAction func barBtnCreateNewListAction(_ sender: Any) {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        groups = [:]
        setUpMenu()
        setLocalizedText()
        self.hideKeyboardWhenTappedAround()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getUserDataFromDatabase()
    }
    func setUpMenu(){
        leadingConstraint.constant = -295
        menuView.layer.shadowOpacity = 0.5
        menuView.layer.shadowRadius = 8
    }
    
    func setLocalizedText(){
        txtSignOut.text = NSLocalizedString("menuDisconnect", comment: "signout text")
        txtEditAccount.text = NSLocalizedString("menuEditAccount", comment: "editaccount text")
        txtCreateNewList.text = NSLocalizedString("menuCreateNew", comment: "createnewlist text")
        navigationItem.title = NSLocalizedString("appname", comment: "app name")
    }
    
    func showMenuAnimation(){
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func getUserDataFromDatabase(){
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
        ref.observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let email = value?["email"] as? String ?? ""
            let name = value?["name"] as? String ?? ""
            let telephone = value?["telephone"] as? String ?? ""
            self.user = User.init(name: name, email: email, telephone: telephone)
            var groups: [String: String] = [:]
            var cont : Int = 0
            if snapshot.childSnapshot(forPath: "groups").childrenCount > 0{
                let childSnapshot = snapshot.childSnapshot(forPath: "groups")
                for subValue in childSnapshot.children{
                    let subSnap = subValue as! DataSnapshot
                    groups[String(cont)] = subSnap.value as? String
                    self.getUserGroupDataFromDatabase(groupID: (subSnap.value as? String)!)
                    cont = cont + 1
                }
            }
            if groups.count > 0 {
                self.user?.setGroups(groups: groups)
            }
            self.setUserText()
            self.tableView.reloadData()
        })
        ref.keepSynced(true)
    }
    
    func getUserGroupDataFromDatabase(groupID: String){
        let ref = Database.database().reference().child("groups").child(groupID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let name = value?["name"] as? String ?? ""
            let description = value?["description"] as? String ?? ""
            let g = Group.init(name: name, description: description)
            g.setId(id: groupID)
            var users: [String: String] = [:]
            var cont = 0
            if snapshot.childSnapshot(forPath: "users").childrenCount > 0{
                let childSnapshot = snapshot.childSnapshot(forPath: "users")
                for subValue in childSnapshot.children{
                    let subSnap = subValue as! DataSnapshot
                    users[String(cont)] = subSnap.value as? String
                    cont = cont + 1
                }
            }
            for (_, val) in users{
                g.setUsers(uID: val)
            }
            self.groups?[groupID] = g
            self.groupsID.append(groupID)
            self.tableView.reloadData()
        })
        ref.keepSynced(true)
    }
    func setUserText(){
        txtName.text = user?.name
        txtNumber.text = user?.telephone
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainMenuToCreateList" {
            let nextScene = segue.destination as? CreateNewListViewController
            nextScene?.user = self.user
            groupsID.removeAll()
        }else if segue.identifier == "mainMenuToEditAccount"{
            let nextScene = segue.destination as? EditAccountViewController
            nextScene?.user = self.user
        }else if segue.identifier == "mainMenuToItemView"{
            let pos: Int? = sender as? Int
            let nextScene = segue.destination as? ItemListViewController
            nextScene?.user = self.user
            nextScene?.group = self.groups?[groupsID[pos!]]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return(groups?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GroupTableViewCell
        if (groups?.count)! > 0{
            cell.txtName?.text = groups?[groupsID[indexPath.row]]?.name
            cell.txtDescription?.text = groups?[groupsID[indexPath.row]]?.description
            if let firstLetter = groups?[groupsID[indexPath.row]]?.name.characters.first{
                cell.txtGroupLetter.text = String(firstLetter).uppercased()
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if(editingStyle == UITableViewCellEditingStyle.delete){
            showDeleteDialog(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "mainMenuToItemView", sender: indexPath.row)
    }
    
    func showDeleteDialog(indexPath: IndexPath){
        let refreshAlert = UIAlertController(title: NSLocalizedString("deleteGroupDialogTitle", comment: "alert title"), message: NSLocalizedString("deleteGroupDialogMsg", comment: "alert msg"), preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("deleteGroupDialogBtnOk", comment: "alert ok"), style: .default, handler: { (action: UIAlertAction!) in
            self.deleteGroupFromUser(indexPath: indexPath)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: NSLocalizedString("deleteGroupDialogBtnCancel", comment: "alert cancel"), style: .cancel, handler: { (action: UIAlertAction!) in
            self.tableView.reloadData()
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func deleteGroupFromUser(indexPath: IndexPath){
        DatabaseFunctions.deleteGroupFromUser(user: user!, gID: groupsID[indexPath.row])
        DatabaseFunctions.deleteUserFromGroup(uID: (Auth.auth().currentUser?.uid)!, group: (groups?[groupsID[indexPath.row]])!)
        groups?.removeValue(forKey: self.groupsID[indexPath.row])
        groupsID.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
}
