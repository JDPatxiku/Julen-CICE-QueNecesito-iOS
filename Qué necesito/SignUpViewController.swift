//
//  SignUpViewController.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 3/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import UIKit
import FirebaseAuth
class SignUpViewController: UIViewController {
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtEmail: UILabel!
    @IBOutlet weak var txtPassword: UILabel!
    @IBOutlet weak var txtRepeatPassword: UILabel!
    @IBOutlet weak var txtNumber: UILabel!
    @IBOutlet weak var txtLogIn: UILabel!
    @IBOutlet weak var edtName: UITextField!
    @IBOutlet weak var edtEmail: UITextField!
    @IBOutlet weak var edtPassword: UITextField!
    @IBOutlet weak var edtRepeatPassword: UITextField!
    @IBOutlet weak var edtNumber: UITextField!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityViewIndicator: UIActivityIndicatorView!
    
    @IBAction func btnSignUp(_ sender: Any) {
        prepareForSignUp()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocalizedText()
        edtNumber.keyboardType = UIKeyboardType.numberPad
        setUpScrollBehaviour()
        self.hideKeyboardWhenTappedAround()
    }
    
    func setUpScrollBehaviour(){
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        scrollView.isScrollEnabled = false
    }
    
    func setLocalizedText(){
        txtEmail.text = NSLocalizedString("signUpEmail", comment: "email text")
        txtPassword.text = NSLocalizedString("signUpPassword", comment: "password text")
        txtName.text = NSLocalizedString("signUpName", comment: "name text")
        txtRepeatPassword.text = NSLocalizedString("signUpRepeatPassword", comment: "repear password text")
        txtNumber.text = NSLocalizedString("signUpNumber", comment: "number text")
        txtLogIn.text = NSLocalizedString("signUpAccountAlready", comment: "login text")
        btnSignUp.setTitle(NSLocalizedString("signUpText", comment: "button text"), for: .normal)
    }
    
    func prepareForSignUp(){
        if edtName.text != ""{
            if edtEmail.text != "" && validateEmail(email: edtEmail.text!){
                if edtPassword.text != "" && edtRepeatPassword.text != ""{
                    if edtPassword.text == edtRepeatPassword.text{
                        if (edtPassword.text?.characters.count)! >= 6{
                            if edtNumber.text != ""{
                                getIfNumberIsUsed()
                            }else{
                                Toast.showInParent(self.view, NSLocalizedString("signUpNumberNotAchieved", comment: "error text"), duration: "s")
                            }
                        }else{
                            Toast.showInParent(self.view, NSLocalizedString("signUpPasswordLengthError", comment: "error text"), duration: "s")
                        }
                    }else{
                        Toast.showInParent(self.view, NSLocalizedString("signUpPasswordMatchError", comment: "error text"), duration: "s")
                    }
                }else{
                    Toast.showInParent(self.view, NSLocalizedString("signUpPasswordEmptyError", comment: "error text"), duration: "s")
                }
            }else{
                Toast.showInParent(self.view, NSLocalizedString("signUpEmailError", comment: "error text"), duration: "s")
            }
        }else{
            Toast.showInParent(self.view, NSLocalizedString("signUpNameError", comment: "error text"), duration: "s")
        }
    }
    
    func signUp(){
        Auth.auth().createUser(withEmail: edtEmail.text!, password: edtPassword.text!){ (user, error) in
            if error != nil{
                Toast.showInParent(self.view, NSLocalizedString("signUpError", comment: "error text"), duration: "s")
                DispatchQueue.main.async {
                    self.enableComponents()
                    return
                }
            }
            self.createAccountData()
        }
    }
    
    func createAccountData(){
        let u = User.init(name: edtName.text!, email: edtEmail.text!, telephone: edtNumber.text!)
        DatabaseFunctions.updateUser(user: u)
        DatabaseFunctions.updateNumberData(number: edtNumber.text!)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "signUpToLogIn", sender: self)
        }
    }
    
    func getIfNumberIsUsed(){
        disableComponents()
        let url = URL(string: "https://us-central1-grocery-a6978.cloudfunctions.net/checkIfNumberExists?number="+edtNumber.text!)
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.enableComponents()
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.enableComponents()
                }
                return
            }
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            if !self.checkIfNumberIsUsed(json: json){
                self.signUp()
            }
            DispatchQueue.main.async {
                self.enableComponents()
            }
        }
        task.resume()
    }
    func checkIfNumberIsUsed(json : Any) -> Bool{
        if let values = json as? [String: Any]{
            if let exists = values["match"] as? String{
                if exists == "true"{
                    DispatchQueue.main.async {
                        Toast.showInParent(self.view, NSLocalizedString("signUpNumberExistsError", comment: "error text"), duration: "s")
                    }
                    return true
                }
            }
        }
        return false
    }
    
    
    func validateEmail(email :String) -> Bool{
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let formatedEmail = NSPredicate(format:"SELF MATCHES %@", regEx)
        return formatedEmail.evaluate(with: email)
    }
    
    func disableComponents(){
        activityViewIndicator.startAnimating()
        edtName.isEnabled = false
        edtEmail.isEnabled = false
        edtPassword.isEnabled = false
        edtRepeatPassword.isEnabled = false
        edtNumber.isEnabled = false
        btnSignUp.isEnabled = false
    }
    func enableComponents(){
        activityViewIndicator.stopAnimating()
        edtName.isEnabled = true
        edtEmail.isEnabled = true
        edtPassword.isEnabled = true
        edtRepeatPassword.isEnabled = true
        edtNumber.isEnabled = true
        btnSignUp.isEnabled = true
    }
    
    func keyboardWillShow(notification:NSNotification) {
        scrollView.isScrollEnabled = true
    }
    
    func keyboardWillHide(notification:NSNotification) {
        scrollView.scrollTop()
        scrollView.isScrollEnabled = false
    }
}
