//
//  LoginViewController.swift
//  XWorkerBee
//
//  Created by Chan on 3/27/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit
import OneSignal
import SwiftyJSON
import Alamofire
import CoreTelephony
import SystemConfiguration
import SwiftKeychainWrapper

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblTitel1: UILabel!
    @IBOutlet weak var lblTitle2: UILabel!
    @IBOutlet weak var tfUserCode: UITextField!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var sv: UIScrollView!
    @IBOutlet weak var v: UIView!
    @IBOutlet weak var btCopy: UIButton!
    @IBOutlet weak var lbInfoDevice: UILabel!
    private var infoDevice: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //set background image
        SharedClass.sharedInstance.backgroundImage(view: self.view)
        
        tfUserCode.tag = 0
        tfUserCode.keyboardType = UIKeyboardType.default
        tfUserCode.returnKeyType = UIReturnKeyType.next
        tfUserCode.layer.cornerRadius = 20
        tfUserCode.clipsToBounds = true
        tfUserCode.delegate = self
        tfUserCode.attributedPlaceholder = NSAttributedString(string: "Mã tài khoản",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tfUserName.tag = 1
        tfUserName.keyboardType = UIKeyboardType.default
        tfUserName.returnKeyType = UIReturnKeyType.next
        tfUserName.layer.cornerRadius = 20
        tfUserName.clipsToBounds = true
        tfUserName.delegate = self
        tfUserName.attributedPlaceholder = NSAttributedString(string: "Tên đăng nhập",
                                                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tfPassword.tag = 2
        tfPassword.keyboardType = UIKeyboardType.default
        tfPassword.returnKeyType = UIReturnKeyType.done
        tfPassword.layer.cornerRadius = 20
        tfPassword.clipsToBounds = true
        tfPassword.delegate = self
        tfPassword.attributedPlaceholder = NSAttributedString(string: "Mật khẩu",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        btnLogin.tag = 3
        btnLogin.layer.cornerRadius = 20
        

        
        self.btCopy.clipsToBounds = true
        self.btCopy.layer.cornerRadius = 10

        self.getKeyChain()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        if let _ = UserDefaults.standard.string(forKey: User.ACCOUNT_CODE){
            tfUserCode?.text = UserDefaults.standard.string(forKey: User.ACCOUNT_CODE)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
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
    

    @IBAction func btnLoginAction(_ sender: UIButton!) {
        //get uuid

        
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 3 {
            if(tfUserCode.text == "" || tfUserName.text == "" || tfPassword.text == ""){
                self.view!.makeToast("Vui lòng điền mã tài khoản, tên đăng nhập và mật khẩu", duration: 2.0, position: .center)
            }else{
                Utils.loading(self.view, startAnimate: true)
                RequestManager.login(userCode: (tfUserCode.text)!, userName: (tfUserName.text)!, password: (tfPassword.text)!, infoDevice: self.lbInfoDevice.text ?? "", completionHandler: {(status, msgLogin) -> Void in
                  if status {
                    if let result = msgLogin.dictionary {
                        if let userID = result["idNhanVien"]?.string {
                            RequestManager.isAccountValid(userCode: userID , infoDevice: self.lbInfoDevice.text ?? "", completionHandler: { (status, msg) in
                                if status {
                                    if msg["KetQua"] == 1 {
                                        if let result = msgLogin.dictionary{
                                            let userId = result["idNhanVien"]?.string
                                            if(userId != nil){
                                                RequestManager.getUserStatus(userId: userId!, completionHandler: {(status, msg) -> Void in
                                                    if(status){
                                                        if let userStatus = msg.dictionary{
                                                            Utils.loading(self.view, startAnimate: false)
                                                            let expire = userStatus["GiaHan"]?.int
                                                            let lock = userStatus["Block"]?.int
                                                            if(lock == Constant.USER_STATUS_BLOCK){
                                                                self.view.makeToast("Rất tiếc. Tài khoản của bạn đã bị khoá!!!", duration: 2.0, position: .center)
                                                            }else{
                                                                if(expire == Constant.USER_STATUS_EXPIRE){
                                                                    self.view.makeToast("Rất tiếc. Tài khoản của bạn đã hết hạn!!!", duration: 2.0, position: .center)
                                                                }else{
                                                                    UserDefaults.standard.set(result["idNhanVien"]?.string, forKey: User.USER_ID)
                                                                    //UserDefaults.standard.set(result["XetBanKinh"]?.int == Constant.KEY_NEED_CHECK_RADIUS ? true : false, forKey: User.USER_CHECK_RADIUS)
                                                                    UserDefaults.standard.set(result["MaNhanVien"]?.string, forKey: User.USER_CODE)
                                                                    UserDefaults.standard.set(result["HoTen"]?.string, forKey: User.USER_FULL_NAME)
                                                                    UserDefaults.standard.set(result["LinkHinhAnh"]?.string, forKey: User.USER_AVATAR)
                                                                    UserDefaults.standard.set(result["ChucVu"]?.string, forKey: User.USER_JOB_TITLE)
                                                                    UserDefaults.standard.set("App Chấm Công XWorkerBee", forKey: User.COMPANY_NAME)
                                                                    UserDefaults.standard.set(self.tfUserCode?.text, forKey: User.ACCOUNT_CODE)
                                                                    UserDefaults.standard.set(self.tfUserName?.text, forKey: User.USER_NAME)
                                                                    //UserDefaults.standard.set(Menu.CHAM_CONG_MENU, forKey: User.MENU_SELECTED)
                                                                    
                                                                    //save player id to server
                                                                    
                                                                    let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                                                                    if let playerID = status.subscriptionStatus.userId{
                                                                        RequestManager.setPlayerID(userID: (result["idNhanVien"]?.string)!, playerID: playerID, completionHandler: {(status, msg) -> Void in
                                                                            self.dismiss(animated: true, completion: nil)
                                                                        })
                                                                    }else{
                                                                        self.dismiss(animated: true, completion: nil)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                })
                                            }else{
                                                Utils.loading(self.view, startAnimate: false)
                                                let alert = UIAlertController(title: "Đăng nhập", message: "Tên đăng nhập hoặc mật khẩu không đúng", preferredStyle: UIAlertController.Style.alert)
                                                alert.addAction(UIAlertAction(title: "Đóng", style: UIAlertAction.Style.default, handler: nil))
                                                self.present(alert, animated: true, completion: nil)
                                            }
                                        }
                                    } else {
                                        Utils.loading(self.view, startAnimate: false)
                                        self.view.makeToast("Tài khoản không hợp lệ", duration: 2.0, position: .center)
                                    }
                                } else {
                                    Utils.loading(self.view, startAnimate: false)
                                    self.view.makeToast("Tài khoản không hợp lệ", duration: 2.0, position: .center)
                                }
                            })
                        } else {
                            let isWrongInfo = result["SaiThongSoMay"]?.string
                            self.showAlertWrongPasswordOrInfoDevice(json: isWrongInfo)
                        }
                        }
                  }else {
                            if(msgLogin.string == "timeout"){
                                Utils.loading(self.view, startAnimate: false)
                                self.view.makeToast("Đang xử lý.....", duration: 2.0, position: .center)
                            }else{
                                Utils.loading(self.view, startAnimate: false)
                                let alert = UIAlertController(title: "Đăng nhập", message: "Tên đăng nhập hoặc mật khẩu không đúng", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Đóng", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        
                    })
                    }
        }
    }
    @IBAction func btCopyAction(_ sender: UIButton) {
        UIPasteboard.general.string = self.lbInfoDevice.text
        Utils.loading(self.view, startAnimate: false)
        self.view.makeToast("Copy thành công", duration: 2.0, position: .center)
    }
    
    private func getKeyChain() {
        if let valueInfoDevice: String = KeychainWrapper.standard.string(forKey: "infoDevice") {
            self.lbInfoDevice.text = valueInfoDevice
        } else {
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                let prefixIndex = uuid.md5().index(uuid.md5().startIndex, offsetBy: 16)
                self.lbInfoDevice.text = String(uuid.md5().prefix(upTo: prefixIndex))
                KeychainWrapper.standard.set(self.lbInfoDevice.text ?? "", forKey: "infoDevice")
            }
        }
    }
    
    private func showAlertWrongPasswordOrInfoDevice(json: String?) {
        guard json != nil else {
            Utils.loading(self.view, startAnimate: false)
            let alert = UIAlertController(title: "Đăng nhập", message: "Tên đăng nhập hoặc mật khẩu không đúng", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Đóng", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        Utils.loading(self.view, startAnimate: false)
        self.view.makeToast("Tài khoản không hợp lệ", duration: 2.0, position: .center)
    }
}



