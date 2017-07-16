//
//  Toast.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 4/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import UIKit

public class Toast: UIView {
    private static let SHORT_TIME = 1.5
    private static let LONG_TIME = 3.0
    
    private static let hLabelGap: CGFloat = 40.0
    private static let vLabelGap: CGFloat = 20.0
    private static let hToastGap: CGFloat = 20.0
    private static let vToastGap: CGFloat = 10.0
    
    private var textLabel: UILabel!
    
    static func showInParent(_ parentView: UIView, _ text: String, duration: Character) {
        let labelFrame = CGRect(x: parentView.frame.origin.x + hLabelGap,
                                y: parentView.frame.origin.y + vLabelGap,
                                width: parentView.frame.width - 2 * hLabelGap,
                                height: parentView.frame.height - 2 * vLabelGap)
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.text = text
        label.backgroundColor = UIColor.clear
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.frame = labelFrame
        label.sizeToFit()
        
        let toast = Toast()
        toast.textLabel = label
        toast.addSubview(label)
        toast.frame = CGRect(x: label.frame.origin.x - hToastGap,
                             y: label.frame.origin.y - vToastGap,
                             width: label.frame.width + 2 * hToastGap,
                             height: label.frame.height + 2 * vToastGap)
        toast.backgroundColor = UIColor.darkGray
        toast.alpha = 0.0
        toast.layer.cornerRadius = 20.0
        toast.center = parentView.center
        label.center = CGPoint(x: toast.frame.size.width / 2, y: toast.frame.size.height / 2)
        
        parentView.addSubview(toast)
        
        UIView.animate(withDuration: 0.4, animations: {
            toast.alpha = 0.9
            label.alpha = 0.9
        })
        
        toast.perform(#selector(hideSelf), with: nil, afterDelay: duration == "s" ? SHORT_TIME : LONG_TIME)
    }
    
    @objc private func hideSelf() {
        UIView.animate(withDuration: 0.4, animations: {
            self.alpha = 0.0
            self.textLabel.alpha = 0.0
        }, completion: { t in self.removeFromSuperview() })
    }
}
