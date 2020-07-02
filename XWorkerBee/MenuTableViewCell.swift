//
//  MenuTableViewCell.swift
//  XWorkerBee
//
//  Created by Chan on 3/27/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit
import BadgeSwift

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var lblBadge: BadgeSwift?
    @IBOutlet weak var lblMenuTitle: UILabel!
    @IBOutlet weak var imgMenuIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
