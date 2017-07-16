//
//  GroupTableViewCell.swift
//  Qué necesito
//
//  Created by Julen Diéguez Amunárriz on 7/7/17.
//  Copyright © 2017 Julen Diéguez Amunárriz. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var txtGroupLetter: UILabel!
    @IBOutlet weak var txtName: UILabel!
    @IBOutlet weak var txtDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.roundView.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
