//
//  TestViewController.swift
//  XWorkerBee
//
//  Created by Chan on 4/15/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var tfHide: UITextField!
    
    var hideStatus: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnAction(_ sender: Any) {
        
        if(!hideStatus){
            tfHide.isHidden = true
            self.hideStatus = true
        }else{
            tfHide.isHidden = false
            self.hideStatus = false
        }
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
