//
//  EditAccountViewController.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 6/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import UIKit

class EditAccountViewController: UIViewController{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fadingView: UIView!
    @IBOutlet weak var txtNameDisplay: UILabel!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var edtName: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var btnSaveEditAccount: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func btnSaveEditAction(_ sender: Any) {
        prepareToUpdateUserName()
    }
    @IBAction func btnEditAccountNameAction(_ sender: Any) {
        showSubView()
    }
    
    var user: User?
    var viewShown: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.tintColor = UIColor.white
        setLocalizedText()
        setUpScrollBehaviour()
        setMenuText()
        enableSubView()
        self.hideKeyboardWhenTappedAround()
    }
    
    func setMenuText(){
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = NSLocalizedString("menuEditAccount", comment: "editAccount text")
    }
    
    func setLocalizedText(){
        btnSaveEditAccount.setTitle(NSLocalizedString("editAccountBtn", comment: "edit account button text"), for: .normal)
        txtName.text = NSLocalizedString("editAccountName", comment: "name text")
        txtNameDisplay.text = NSLocalizedString("editAccountName", comment: "name") + " " + (user?.name)!
    }
    
    func setUpScrollBehaviour(){
        NotificationCenter.default.addObserver(self, selector: #selector(EditAccountViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditAccountViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        scrollView.isScrollEnabled = false
    }
    
    func showSubView(){
        if viewShown{
            UIView.animate(withDuration: 0.3, animations: {
                self.fadingView.alpha = 0
            }, completion: { (finished: Bool) in
                self.enableSubView()
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.fadingView.alpha = 1
            }, completion: { (finished: Bool) in
                self.enableSubView()
            })
        }
        viewShown = !viewShown
    }
    
    func prepareToUpdateUserName(){
        enableSubView()
        activityIndicatorView.startAnimating()
        if !checkIfNameFieldIsEmpty(){
            user?.name = edtName.text!
            DatabaseFunctions.updateUser(user: user!)
            enableSubView()
            activityIndicatorView.stopAnimating()
            navigationController?.popViewController(animated: true)
            return
        }
        Toast.showInParent(view, NSLocalizedString("editAccountNameError", comment: "error text"), duration: "s")
        activityIndicatorView.stopAnimating()
        enableSubView()
    }
    
    func checkIfNameFieldIsEmpty() -> Bool{
        return edtName.text == ""
    }
    
    func enableSubView(){
        edtName.isEnabled = !edtName.isEnabled
        btnSaveEditAccount.isEnabled = !btnSaveEditAccount.isEnabled
    }
    
    func keyboardWillShow(notification:NSNotification) {
        scrollView.isScrollEnabled = true
    }
    
    func keyboardWillHide(notification:NSNotification) {
        scrollView.scrollTop()
        scrollView.isScrollEnabled = false
    }
    
}
