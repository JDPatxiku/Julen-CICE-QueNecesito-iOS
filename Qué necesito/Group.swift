//
//  group.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 5/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import Foundation

public class Group{
    public var name: String = ""
    public var description: String = ""
    public var id: String = ""
    public var users: [String: String] = [:]
    public var items: [String: String] = [:]
    
    init(name: String, description: String){
        self.name = name
        self.description = description
        self.users = [:]
        self.items = [:]
    }
    
    public func setId(id : String){
        self.id = id
    }
    
    public func setUsers(uID: String){
        self.users[String(users.count)] = uID
    }
    
    public func setItems(iID: String){
        self.items[String(items.count)] = iID
        print("wololo")
    }
    
    public func removeUser(uID: String){
        var index: String?
        for (key, element) in self.users{
            if element == uID{
                index = key
            }
        }
        self.users.removeValue(forKey: index!)
    }
    
    public func removeItem(iID: String){
        var index: String?
        for (key, element) in self.items{
            if element == iID{
                index = key
            }
        }
        self.items.removeValue(forKey: index!)
    }
    
    public func checkIfShouldBeRemoved() -> Bool{
        return self.users.count <= 0
    }
    
}
