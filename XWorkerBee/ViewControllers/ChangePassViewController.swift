//
//  ChangePassViewController.swift
//  XWorkerBee
//
//  Created by Chan on 2/8/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ChangePassViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tfOldPass: UITextField!
    @IBOutlet weak var tfNewPass: UITextField!
    @IBOutlet weak var tfNewPassConfirm: UITextField!
    @IBOutlet weak var btnChangePass: UIButton!
    @IBOutlet weak var v: UIView!
    private var countView: Int = 0
    private var arr: [Dictionary<String,Any>] = [Dictionary<String,Any>]()
    
    @IBAction func btnChangePassAction(_ sender: Any) {
        if(tfOldPass?.text == "" || tfNewPass?.text == "" || tfNewPassConfirm?.text == ""){
            self.view.makeToast("Vui lòng điền đầy đủ thông tin", duration: 2.0, position: .center)
        }else{
            if(tfNewPass?.text != tfNewPassConfirm?.text)
            {
                self.view.makeToast("Mật khẩu mới và mật khẩu xác nhận không khớp", duration: 2.0, position: .center)
            }else{
                Utils.loading(self.view, startAnimate: true)
                RequestManager.changePassword(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, oldPass: (tfOldPass?.text)!, newPass: (tfNewPass?.text)!, completionHandler: {(status, msg) -> Void in
                    Utils.loading(self.view, startAnimate: false)
                    if(status){
                        if let result = msg.dictionary{
                            let changePassStatus = result["KetQua"]?.int
                            if(changePassStatus == 1){
                                self.view.makeToast("Đổi mật khẩu thành công", duration: 2.0, position: .center)
                                self.tfNewPassConfirm?.text = ""
                                self.tfNewPass?.text = ""
                                self.tfOldPass?.text = ""
                            }else{
                                self.view.makeToast("Mật khẩu cũ không đúng", duration: 2.0, position: .center)
                            }
                        }
                    }
                })
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        //setup title
        let navView = Utils.configTitleNavBar(navBar: (self.navigationController?.navigationBar)!)
        self.navigationItem.titleView = navView
        navView.sizeToFit()
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.barTintColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR)
        
        //setup background
        SharedClass.sharedInstance.backgroundImage(view: self.view)
        
        
        //Register show badge when receive notification
        //NotificationCenter.default.addObserver(self, selector: #selector(ChangePassViewController.showBadgeAtChangePassVC), name: .showBadgeAtChangePassVC, object: nil)
        
        tfOldPass!.layer.cornerRadius = Constant.BORDER_RADIUS
        tfOldPass.attributedPlaceholder = NSAttributedString(string: "Mật khẩu cũ",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tfNewPass!.layer.cornerRadius = Constant.BORDER_RADIUS
        tfNewPass.attributedPlaceholder = NSAttributedString(string: "Mật khẩu mới",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tfNewPassConfirm!.layer.cornerRadius = Constant.BORDER_RADIUS
        tfNewPassConfirm.attributedPlaceholder = NSAttributedString(string: "Nhập lại mật khẩu mới",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        btnChangePass!.layer.cornerRadius = Constant.BORDER_RADIUS

        tfOldPass.delegate = self
        tfNewPass.delegate = self
        tfNewPassConfirm.delegate = self
        
        tfOldPass!.tag = 0
        tfOldPass.keyboardType = UIKeyboardType.default
        tfOldPass.returnKeyType = UIReturnKeyType.next
        
        tfNewPass.tag = 1
        tfNewPass!.keyboardType = UIKeyboardType.default
        tfNewPass!.returnKeyType = UIReturnKeyType.next
        
        tfNewPassConfirm.tag = 2
        tfNewPassConfirm!.keyboardType = UIKeyboardType.default
        tfNewPassConfirm!.returnKeyType = UIReturnKeyType.done
        checkViewedNotification()
//        self.detecNextSchedule()
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenAppFromBG),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    @objc func handleOpenAppFromBG(){
        checkViewedNotification()
//        self.detecNextSchedule()
    }
    
    override func viewWillAppear(_ animated: Bool) {
           Utils.showBadgeNumber(navItem: self.navigationItem, index: 0)
//        //show notification number badge
//        NotificationCenter.default.post(name: .showBadgeAtNotificationVC, object: nil)
//
//        //set notification right bar item menu
//        let notiMenu = UIButton(type: .custom)
//        notiMenu.setImage(#imageLiteral(resourceName: "ic_bell"), for: .normal)
//        notiMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        notiMenu.addTarget(self, action: #selector(ChangePassViewController.openNotificationViewByMenu), for: .touchUpInside)
//        let rightBarBtnUser = UIBarButtonItem(customView: notiMenu)
//        self.navigationItem.setRightBarButtonItems([rightBarBtnUser], animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
     
    }
//
//    @objc func openNotificationViewByMenu() {
//        if let identifierMenuActived = UserDefaults.standard.string(forKey: User.MENU_SELECTED){
//            if(identifierMenuActived != Menu.NHAC_NHO_MENU){
//                //set menu is actived
//                UserDefaults.standard.set(Menu.NHAC_NHO_MENU, forKey: User.MENU_SELECTED)
//                //open view by menu
//                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let dovc = storyBoard.instantiateViewController(withIdentifier: Menu.NHAC_NHO_MENU) as! NotificationViewController
//                self.navigationController?.pushViewController(dovc, animated: true)
//            }
//        }
//    }
//
//    @objc func showBadgeAtChangePassVC() {
//        Utils.showBadgeNumber(navItem: self.navigationItem, index: 0)
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Utils.loading(self.view, startAnimate: false)
    }
    private func checkViewedNotification(){
        self.getNotificationList { (arrtemp) -> [Dictionary<String, Any>] in
            for i in arrtemp {
                
                if i["viewed"] as! Int == 1 {
                    
                }else {
                    self.countView += 1
                }}
                if self.countView > 0 {
                    self.addSlideMenuButton(allViewed: true, countNotView: self.countView)
                    UIApplication.shared.applicationIconBadgeNumber = self.countView
                } else {
                    self.addSlideMenuButton(allViewed: false, countNotView: self.countView)
                }
            return arrtemp
        }
    }
    private func getNotificationList(completion: @escaping ([Dictionary<String,Any>]) -> [Dictionary<String,Any>]){
        self.arr.removeAll()
        self.countView = 0
        Utils.loading(self.view, startAnimate: true)
        RequestManager.getNotificationList(userID: UserDefaults.standard.string(forKey: User.USER_ID) ?? "", completionHandler: {(status, msg) -> Void in
            Utils.loading(self.view, startAnimate: false)
            if(status){
                if let result = msg.array{
                    var listId = ""
                    for (index, item) in result.enumerated(){
                        let dc = ["title":item["title"].string!,
                                  "content": item["contents"].string!,
                                  "viewed": item["isDaXem"].int,
                                  "notification_id": item["notification_id"].string!,
                                  "id": item["id"].string!] as [String : Any]
                        self.arr.append(dc)
                        if(((msg.array?.count)! - 1) == index){
                            listId = listId + item["id"].string!
                        }else{
                            listId = listId + item["id"].string! + "_"
                        }
                    }
                    completion(self.arr)
                }
            }
        })
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height / 2
                self.v.heightConstaint?.constant = UIScreen.main.bounds.height + keyboardSize.height / 2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
             self.v.heightConstaint?.constant = UIScreen.main.bounds.height
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            return true;
        }
        return false
        
    }
    
}
