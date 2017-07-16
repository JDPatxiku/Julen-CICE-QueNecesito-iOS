//
//  User.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 4/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import Foundation

public class User{
    public var name: String = ""
    public var email: String = ""
    public var telephone: String = ""
    public var groups: [String: String] = [:]
    
    init(name: String, email: String, telephone: String){
        self.name = name
        self.email = email
        self.telephone = telephone
        self.groups = [:]
    }
    
    public func setGroups(groups: [String: String]){
        self.groups = groups
    }
    public func addGroup(group: String){
        self.groups[String((self.groups.count))] = group
    }

    public func removeGroup(gID: String){
        var index: String?
        for (key, element) in self.groups{
            if element == gID{
                index = key
            }
        }
        self.groups.removeValue(forKey: index!)
    }
    
}
