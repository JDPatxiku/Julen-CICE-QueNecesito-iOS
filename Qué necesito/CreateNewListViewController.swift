//
//  CreateNewListViewController.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 5/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class CreateNewListViewController: UIViewController {
    
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtDescription: UILabel!
    @IBOutlet weak var edtName: UITextField!
    @IBOutlet weak var edtDescription: UITextField!
    @IBOutlet weak var btnCreateNew: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func btnCreateNewAction(_ sender: Any) {
        prepareToCreate()
    }    
    public var user: User?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setMenuText()
        setLocalizedText()
        setUpScrollBehaviour()
        self.hideKeyboardWhenTappedAround()        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.tintColor = UIColor.white
    }
    
    func setUpScrollBehaviour(){
        NotificationCenter.default.addObserver(self, selector: #selector(CreateNewListViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateNewListViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        scrollView.isScrollEnabled = false
    }
    
    func setMenuText(){
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = NSLocalizedString("createListButton", comment: "createList text")
    }
    func setLocalizedText(){
        txtName.text = NSLocalizedString("createListName", comment: "name text")
        txtDescription.text = NSLocalizedString("createListDescription", comment: "description text")
        btnCreateNew.setTitle(NSLocalizedString("createListButton", comment: "button text"), for: .normal)
    }
    
    func prepareToCreate(){
        disableComponents()
        if checkRequirements(){
            createGroup()
            updateUserGroup()
            enableComponents()
            navigationController?.popViewController(animated: true)
        }else{
            enableComponents()
        }
    }
    
    func checkRequirements() -> Bool{
        if edtName.text == ""{
            Toast.showInParent(view, NSLocalizedString("createListNameLengthError", comment: "error text"), duration: "s")
            return false
        }
        if edtDescription.text == ""{
            Toast.showInParent(view, NSLocalizedString("createListDescriptionLengthError", comment: "error text"), duration: "s")
            return false
        }
        return true
    }
    
    func createGroup(){
        let g = Group.init(name: edtName.text!, description: edtDescription.text!)
        g.setId(id: Database.database().reference().childByAutoId().key)
        g.setUsers(uID: (Auth.auth().currentUser?.uid)!)
        user?.addGroup(group: g.id)
        DatabaseFunctions.updateGroup(group: g)
    }
    
    func updateUserGroup(){
        DatabaseFunctions.updateUser(user: user!)
    }
    
    func disableComponents(){
        activityIndicatorView.startAnimating()
        edtName.isEnabled = false
        edtDescription.isEnabled = false
        btnCreateNew.isEnabled = false
    }
    func enableComponents(){
        activityIndicatorView.stopAnimating()
        edtName.isEnabled = true
        edtDescription.isEnabled = true
        btnCreateNew.isEnabled = true
    }
    
    func keyboardWillShow(notification:NSNotification) {
        scrollView.isScrollEnabled = true
    }
    
    func keyboardWillHide(notification:NSNotification) {
        scrollView.scrollTop()
        scrollView.isScrollEnabled = false
    }
}
