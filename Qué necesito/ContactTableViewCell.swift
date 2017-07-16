//
//  ContactTableViewCell.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 12/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {
    @IBOutlet weak var letterView: UIView!
    @IBOutlet weak var txtLetter: UILabel!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtNumber: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.letterView.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
