//
//  CreateItemViewController.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 11/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import UIKit
import Firebase

class CreateItemViewController: UIViewController, UITextFieldDelegate {
    public var group: Group?
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtBrand: UILabel!
    @IBOutlet weak var txtPrice: UILabel!
    @IBOutlet weak var txtQuantity: UILabel!
    @IBOutlet weak var btnCreateNewItem: UIButton!
    @IBOutlet weak var sldQuantity: UISlider!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var edtName: UITextField!
    @IBOutlet weak var edtBrand: UITextField!
    @IBOutlet weak var edtPrice: UITextField!
    @IBAction func btnCreateNewItemAction(_ sender: Any) {
        prepareToCreateItem()
    }
    
    @IBAction func sldQuantityValueChanged(_ sender: Any) {
        txtQuantity.text = NSLocalizedString("createItemQuantity", comment: "quantity text") + String(Int(sldQuantity.value))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.hideKeyboardWhenTappedAround()
        self.edtPrice.delegate = self
        setMenuText()
        setLocalizedText()
    }
    
    func setMenuText(){
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = NSLocalizedString("createItem", comment: "createItem")
    }
    
    func setLocalizedText(){
        txtName.text = NSLocalizedString("createItemName", comment: "name text")
        txtBrand.text = NSLocalizedString("createItemBrand", comment: "brand text")
        txtPrice.text = NSLocalizedString("createItemPrice", comment: "price text")
        txtQuantity.text = NSLocalizedString("createItemQuantity", comment: "quantity text") + String(Int(sldQuantity.value))
        btnCreateNewItem.setTitle(NSLocalizedString("createItemButton", comment: "button text"), for: .normal)
    }
    
    func prepareToCreateItem(){
        disableComponents()
        if edtName.text != ""{
            var price: Float = 0
            var brand: String = "undefined"
            if edtPrice.text != ""{
                price = Float(edtPrice.text!)!
            }
            if edtBrand.text != ""{
                brand = edtBrand.text!
            }
            createItem(price: price, brand: brand)
        }else{
            Toast.showInParent(view, NSLocalizedString("createItemNameError", comment: "name error text"), duration: "s")
            enableComponents()
        }
    }
    func createItem(price: Float, brand: String){
        let item: Item = Item.init(author: (Auth.auth().currentUser?.uid)!, name: edtName.text!, brand: brand, price: price, quantity: Int(sldQuantity.value))
        item.setID(id: Database.database().reference().childByAutoId().key)
        group?.setItems(iID: item.id)
        DatabaseFunctions.updateItem(item: item)
        DatabaseFunctions.updateGroup(group: group!)
        enableComponents()
        navigationController?.popViewController(animated: true)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { // return NO to
        switch string {
            case "":
                if (textField.text?.characters.count)! > 0{
                    textField.text = textField.text?.substring(to: (textField.text?.index(before: (textField.text?.endIndex)!))!)
                    return true
                }
                return false
            case "0","1","2","3","4","5","6","7","8","9":
                return true
            case ",":
                if textField.text?.range(of: ".") != nil{
                    return false
                }else{
                    if (textField.text?.characters.count)! > 0{
                        textField.text = textField.text! + "."
                    }
                    return false
                }
            default:
                break
        }
        return false
    }
    func enableComponents(){
        activityIndicatorView.stopAnimating()
        edtName.isEnabled = true
        edtBrand.isEnabled = true
        edtPrice.isEnabled = true
        sldQuantity.isEnabled = true
        btnCreateNewItem.isEnabled = true
    }
    
    func disableComponents(){
        activityIndicatorView.startAnimating()
        edtName.isEnabled = false
        edtBrand.isEnabled = false
        edtPrice.isEnabled = false
        sldQuantity.isEnabled = false
        btnCreateNewItem.isEnabled = false
    }
    
    
}
