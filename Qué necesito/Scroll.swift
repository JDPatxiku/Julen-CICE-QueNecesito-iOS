//
//  Scroll.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 6/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import UIKit
extension UIScrollView{
    func scrollTop(){
        setContentOffset(CGPoint(x: 0, y: -contentInset.top), animated: true)
    }
    func scrollBottom(){
        setContentOffset(CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom), animated: true)
    }
}
