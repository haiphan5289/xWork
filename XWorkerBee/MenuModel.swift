//
//  MenuModel.swift
//  XWorkerBee
//
//  Created by Chan on 3/27/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit

class MenuModel{
    var isActived = Bool()
    var icon = UIImage()
    var title = String()
    var identifier = String()
    
    init(isActived: Bool, icon: UIImage, title: String, identifier: String) {
        self.isActived = isActived
        self.icon = icon
        self.title = title
        self.identifier = identifier
    }
}
