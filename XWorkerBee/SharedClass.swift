//
//  SharedClass.swift
//  XWorkerBee
//
//  Created by Chan on 3/27/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit
class SharedClass: NSObject {
    //Shared class instance
    static let sharedInstance = SharedClass()
    
    //Add background image for view's
    func backgroundImage(view: UIView) {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "bg_main"))//Your image name here
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.insertSubview(imageView, at: 0)//To set first of all views in VC
    }
    
    private override init() {
        
    }
    
}
