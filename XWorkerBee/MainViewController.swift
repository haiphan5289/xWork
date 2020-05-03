//
//  MainViewController.swift
//  XWorkerBee
//
//  Created by Chan on 3/27/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add slide menu
        addSlideMenuButton(allViewed: true, countNotView: 20)
        
        //setup title
        let navView = Utils.configTitleNavBar(navBar: (self.navigationController?.navigationBar)!)
        self.navigationItem.titleView = navView
        navView.sizeToFit()
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.barTintColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR)
        
        //setup background
        SharedClass.sharedInstance.backgroundImage(view: self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = UserDefaults.standard.string(forKey: User.USER_ID){
            
            RequestManager.getUserStatus(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, completionHandler: {(status, msg) -> Void in
                if(status){
                    if let userStatus = msg.dictionary{
                        Utils.loading(self.view, startAnimate: false)
                        let expire = userStatus["GiaHan"]?.int
                        let lock = userStatus["Block"]?.int
                        if(lock == Constant.USER_STATUS_BLOCK){
                            //self.view.makeToast("Rất tiếc. Tài khoản của bạn đã bị khoá!!!")
                            Utils.logout()
                            self.openLoginVC()
                        }else{
                            if(expire == Constant.USER_STATUS_EXPIRE){
                                //self.view.makeToast("Rất tiếc. Tài khoản của bạn đã hết hạn!!!")
                                Utils.logout()
                                self.openLoginVC()
                            }
                        }
                    }
                }
            })
        }else{
            self.openLoginVC()
        }
    }
    
    func openLoginVC(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let lvc = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        lvc.modalPresentationStyle = .fullScreen
        self.present(lvc, animated: true, completion: nil)
    }

}
