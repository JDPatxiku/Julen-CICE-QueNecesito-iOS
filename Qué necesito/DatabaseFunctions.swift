//
//  DatabaseFunctions.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 4/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import Firebase
import FirebaseDatabase

public class DatabaseFunctions{
    class func updateUser(user : User){
        let ref = Database.database().reference().child("users")
        let uid = Auth.auth().currentUser?.uid
        var userValues : [String: Any]
        if user.groups.count == 0{
            userValues = ["email": user.email,
                              "name": user.name,
                              "telephone": user.telephone]
        }else{
            userValues = ["email": user.email,
                              "name": user.name,
                              "telephone": user.telephone,
                              "groups": user.groups] as [String: Any]
        }
        let childUpdates = [(uid)! : userValues]
        ref.updateChildValues(childUpdates)
    }
    class func updateOtherUser(user: User, uID: String){
        let ref = Database.database().reference().child("users")
        var userValues : [String: Any]
        if user.groups.count == 0{
            userValues = ["email": user.email,
                          "name": user.name,
                          "telephone": user.telephone]
        }else{
            userValues = ["email": user.email,
                          "name": user.name,
                          "telephone": user.telephone,
                          "groups": user.groups] as [String: Any]
        }
        let childUpdates = [(uID) : userValues]
        ref.updateChildValues(childUpdates)
    }
    class func updateNumberData(number : String){
        Database.database().reference().child("numbers/"+number).setValue(Auth.auth().currentUser?.uid)
    }
    class func updateGroup(group: Group){
        let ref = Database.database().reference().child("groups")
        var groupValues : [String: Any]
        if group.items.count == 0{
            groupValues = ["description": group.description,
                           "name": group.name,
                           "users": group.users] as [String : Any]
        }else{
            groupValues = ["description": group.description,
                           "name": group.name,
                           "users": group.users,
                           "items": group.items] as [String : Any]
        }
        let childUpdates = [group.id : groupValues]
        ref.updateChildValues(childUpdates)
    }
    
    class func updateItem(item: Item){
        let ref = Database.database().reference().child("items")
        let itemValues = ["author": item.author,
                          "brand": item.brand,
                          "name": item.name,
                          "price": item.price,
                          "quantity": item.quantity] as [String: Any]
        let childUpdates = [item.id : itemValues]
        ref.updateChildValues(childUpdates)
    }
    
    class func deleteUserFromGroup(uID: String, group: Group){
        group.removeUser(uID: uID)
        if group.checkIfShouldBeRemoved(){
            Database.database().reference().child("groups").child(group.id).removeValue()
            return
        }
        updateGroup(group: group)
    }
    class func deleteGroupFromUser(user: User, gID: String){
        user.removeGroup(gID: gID)
        updateUser(user: user)
    }
    
    class func deleteItem(iID: String){
        Database.database().reference().child("items").child(iID).removeValue()
    }
    
}
