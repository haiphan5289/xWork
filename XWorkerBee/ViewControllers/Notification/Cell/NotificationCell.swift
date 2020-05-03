//
//  NotificationCell.swift
//  XWorkerBee
//
//  Created by MacbookPro on 11/9/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var vNotificationItem: UIView!
    @IBOutlet weak var lbNotificationDate: UILabel!
    @IBOutlet weak var lbNotificationContent: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let borderWidth = CGFloat(0.3)
        let borderColor = UITableView().separatorColor?.cgColor
        
        vNotificationItem.layer.borderWidth = borderWidth
        vNotificationItem.layer.borderColor = borderColor

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
