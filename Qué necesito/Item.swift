//
//  Item.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 10/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import Foundation
class Item{
    public var id: String = ""
    public var name: String = ""
    public var author: String = ""
    public var group: String = ""
    public var brand: String = ""
    public var price: Float = 0
    public var quantity: Int = 0
    
    init(author: String, name: String, brand: String, price: Float, quantity: Int){
        self.author = author
        self.name = name
        self.brand = brand
        self.price = price
        self.quantity = quantity
    }
    
    func setGroup(group: String){
        self.group = group
    }
    
    func setID(id: String){
        self.id = id
    }
}
