//
//  NetworkViewController.swift
//  XWorkerBee
//
//  Created by Chan on 2/8/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit

class NetworkViewController: UIViewController {

    @IBOutlet weak var btnTryAgain: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnTryAgain.layer.cornerRadius = 20
        SharedClass.sharedInstance.backgroundImage(view: self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(Utils.isConnectedToNetwork()){
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    @IBAction func btnTryAgainAction(_ sender: Any) {
        if(Utils.isConnectedToNetwork()){
            self.dismiss(animated: true, completion: nil)
        }else{
            shake()
        }
    }
    
    func shake(){
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: btnTryAgain.center.x - 5, y: btnTryAgain.center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: btnTryAgain.center.x + 5, y: btnTryAgain.center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        self.btnTryAgain.layer.add(shake, forKey: nil)
    }
}
