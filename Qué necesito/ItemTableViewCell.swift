//
//  ItemTableViewCell.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 10/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var txtQuantity: UILabel!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtBrand: UILabel!
    @IBOutlet weak var txtPrize: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
