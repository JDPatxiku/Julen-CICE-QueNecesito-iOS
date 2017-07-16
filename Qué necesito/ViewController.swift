//
//  ViewController.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 3/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import UIKit
import FirebaseAuth
class ViewController: UIViewController {
    @IBOutlet weak var txtEmail: UILabel!
    @IBOutlet weak var txtPassword: UILabel!
    @IBOutlet weak var edtEmail: UITextField!
    @IBOutlet weak var edtPassword: UITextField!
    @IBOutlet weak var txtRegister: UILabel!
    @IBOutlet weak var btnLogIn: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
    
    @IBAction func btnLogIn(_ sender: Any) {
        logIn()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        checkIfUserIsLoggedIn()
        setUpScrollBehaviour()
        self.hideKeyboardWhenTappedAround()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocalizedText()
    }
    
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "logInToMainMenu", sender: self)
            }
        }
    }
    func setUpScrollBehaviour(){
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        scrollView.isScrollEnabled = false
    }
    func setLocalizedText(){
        txtEmail.text = NSLocalizedString("logInEmail", comment: "email text")
        txtPassword.text = NSLocalizedString("logInPassword", comment: "password text")
        txtRegister.text = NSLocalizedString("logInNoAccountYet", comment: "register text")
        btnLogIn.setTitle(NSLocalizedString("logInText", comment: "button text"), for: .normal)
    }
    
    
    func logIn(){
        let email: String! = edtEmail.text
        let password: String! = edtPassword.text
        if email != "" && password != ""{
            activityIndicatorView.startAnimating()
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    self.activityIndicatorView.stopAnimating()
                    Toast.showInParent(self.view, NSLocalizedString("logInError", comment: "error text"), duration: "l")
                    return
                }
                self.activityIndicatorView.stopAnimating()
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "logInToMainMenu", sender: self)
                }
            }
        }else{
            Toast.showInParent(self.view, NSLocalizedString("logInFieldMissingError", comment: "error text"), duration: "l")
        }
        
    }
    
    func keyboardWillShow(notification:NSNotification) {
        scrollView.isScrollEnabled = true
    }
    
    func keyboardWillHide(notification:NSNotification) {
        scrollView.scrollTop()
        scrollView.isScrollEnabled = false
    }
}

