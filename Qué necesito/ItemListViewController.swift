//
//  ItemListViewController.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 10/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import UIKit
import Firebase

class ItemListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    public var needsLoad: Bool?
    public var group: Group?
    public var user: User?
    private var items: [String: Item]?
    private var itemsID = [String]()
    
    func didFinishView(controller: CreateItemViewController) {
        needsLoad = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setMenuText()
        getItemsFromGroup()
    }
    func setMenuText(){
        self.navigationController?.navigationBar.topItem?.title = " "
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = group?.name
    }
    
    func getItemsFromGroup(){
        let ref = Database.database().reference().child("groups").child((group?.id)!).child("items")
        ref.observe(.value, with: { (snapshot) in
            self.firebaseSharedFunction(snapshot: snapshot)
        })
        ref.observe(.childRemoved, with: { (snapshot) in
            self.firebaseSharedFunction(snapshot: snapshot)
        })
        ref.keepSynced(true)
    }
    
    func firebaseSharedFunction(snapshot: DataSnapshot){
        items = [:]
        itemsID = [String]()
        self.group?.items = [:]
        for child in snapshot.children{
            let childValue = (child as! DataSnapshot).value as? String
            self.group?.setItems(iID: childValue!)
            self.getItemData(iID: childValue!)
        }
        self.tableView.reloadData()
    }
    func getItemData(iID: String){
        let ref = Database.database().reference().child("items").child(iID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if self.items?.index(forKey: iID) == nil && value != nil{
                let name = value?["name"] as? String ?? ""
                let brand = value?["brand"] as? String ?? ""
                let author = value?["author"] as? String ?? ""
                let price = value?["price"] as? Float
                let quantity = value?["quantity"] as? Int
                let item: Item = Item.init(author: author, name: name, brand: brand, price: price!, quantity: quantity!)
                item.setID(id: iID)
                item.setGroup(group: (self.group?.id)!)
                self.items?[iID] = item
                self.itemsID.append(iID)
                self.tableView.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemTableViewCell
        if (items?.count)! > 0{
            if let quantity = items?[itemsID[indexPath.row]]!.quantity{
                cell.txtQuantity.text = "\(quantity)X"
            }
            cell.txtName.text = items?[itemsID[indexPath.row]]?.name
            if items?[itemsID[indexPath.row]]?.brand != "undefined"{
                cell.txtBrand.text = items?[itemsID[indexPath.row]]?.brand
            }else{
                cell.txtBrand.text = ""
            }
            if items?[itemsID[indexPath.row]]?.price == 0{
                cell.txtPrize.text = ""
            }else{
                if var price = items?[itemsID[indexPath.row]]!.price{
                    price = price * Float((items?[itemsID[indexPath.row]]!.quantity)!)
                    cell.txtPrize.text = "\(price)€"
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if(editingStyle == UITableViewCellEditingStyle.delete){
            deleteItemFromGroup(index: indexPath.row)
        }
    }
    
    func deleteItemFromGroup(index: Int){
        group?.removeItem(iID: (items?[itemsID[index]]?.id)!)
        DatabaseFunctions.updateGroup(group: group!)
        DatabaseFunctions.deleteItem(iID: (items?[itemsID[index]]?.id)!)
        var copy = [String]()
        for val in itemsID{
            if val != (items?[itemsID[index]]?.id)!{
                copy.append(val)
            }
        }
        items?.removeValue(forKey: itemsID[index])
        itemsID.removeAll()
        itemsID = copy
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return(itemsID.count)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemListViewToCreateItem"{
            let nextScene = segue.destination as? CreateItemViewController
            nextScene?.group = self.group
        }else if segue.identifier == "itemListViewToContacts"{
            let nextScene = segue.destination as? ContactsViewController
            nextScene?.userNumber = self.user?.telephone
            nextScene?.group = self.group
        }
    }
    
}
