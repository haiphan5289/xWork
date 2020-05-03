//
//  LoginViewController.swift
//  XWorkerBee
//
//  Created by Chan on 2/8/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit
import Toast_Swift
import OneSignal

class LoginViewController1: UIViewController, UITextFieldDelegate {
    
    var tfUserCode, tfUsername, tfPassword: UITextField?
    var btnLogin: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SharedClass.sharedInstance.backgroundImage(view: self.view)
        
        let colorTop =  UIColor(red: 222.0/255.0, green: 132.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 250.0/255.0, green: 207.0/255.0, blue: 138.0/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let yy = Int(screenHeight / 2) + 30
        
        let tfHeight = Constant.TEXT_FIELD_HEIGHT
        let tfWidth = screenWidth * 8 / 10
        let tfFramePass = CGRect(x: 20, y: yy, width: Int(tfWidth), height: Int(Constant.BUTTON_HEIGHT))
        let tfFrameUsername = CGRect(x: 20, y: yy -  (Int(tfHeight + 20)), width: Int(tfWidth), height: tfHeight)
        let tfFrameUsercode = CGRect(x: 20, y: yy -  (Int((tfHeight + 20)*2)), width: Int(tfWidth), height: tfHeight)
        let tfFrameBtnLogin = CGRect(x: 20, y: yy + (Int(tfHeight + 40)), width: Int(tfWidth), height: Int(Constant.BUTTON_HEIGHT))
        
        let iconSize = 15
        let yIcon = 0
        let xIcon = 3
        let iconFrame = CGRect(x: 0, y: 0, width: iconSize + 20, height: iconSize + 5)
        
        let paddingLeft = CGFloat(30)
        
        tfPassword =  UITextField(frame: tfFramePass)
        //        tfPassword!.layer.borderWidth = Constant.BORDER_LINE_HEIGHT
        //        tfPassword!.layer.borderColor = UIColor.black.cgColor
        //        tfPassword!.layer.cornerRadius = Constant.BORDER_RADIUS
        tfPassword!.tag = 2
        
        tfPassword?.center.x = self.view.center.x
        tfPassword!.placeholder = "Mật khẩu"
        tfPassword!.setLeftPaddingPoints(paddingLeft)
        tfPassword!.font = UIFont.systemFont(ofSize: Constant.FONT_SIZE)
        tfPassword!.autocorrectionType = UITextAutocorrectionType.no
        tfPassword!.keyboardType = UIKeyboardType.default
        tfPassword!.returnKeyType = UIReturnKeyType.done
        tfPassword!.clearButtonMode = UITextField.ViewMode.whileEditing
        tfPassword!.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        tfPassword!.isSecureTextEntry = true
        tfPassword!.delegate = self
        tfPassword!.layer.cornerRadius = Constant.BORDER_RADIUS
        tfPassword!.textColor = UIColor.white
        tfPassword!.backgroundColor = Utils.convertHexStringToUIColor(hex: Color.WHITE_COLOR_OPPACITY_70)
        //Utils.addLineToView(view: tfPassword!, position:.LINE_POSITION_BOTTOM, color: UIColor.black, width: Double(Constant.BORDER_LINE_HEIGHT))
        
        let ivPass = UIView(frame: iconFrame)
        let imvPass = UIImageView();
        imvPass.image = #imageLiteral(resourceName: "ic_pass20pt")
        imvPass.frame = CGRect(x: xIcon, y: yIcon, width: iconSize, height: iconSize)
        ivPass.addSubview(imvPass)
        tfPassword!.leftViewMode  = .always
        tfPassword!.leftView = ivPass
        self.view.addSubview(tfPassword!)
        
        tfUsername =  UITextField(frame: tfFrameUsername)
        //        tfUsername!.layer.borderWidth = Constant.BORDER_LINE_HEIGHT
        //        tfUsername!.layer.borderColor = UIColor.black.cgColor
        //        tfUsername!.layer.cornerRadius = Constant.BORDER_RADIUS
        tfUsername!.tag = 1
        
        tfUsername?.center.x = self.view.center.x
        tfUsername!.placeholder = "Tên đăng nhập"
        tfUsername!.setLeftPaddingPoints(paddingLeft)
        tfUsername!.font = UIFont.systemFont(ofSize: Constant.FONT_SIZE)
        tfUsername!.autocorrectionType = UITextAutocorrectionType.no
        tfUsername!.keyboardType = UIKeyboardType.default
        tfUsername!.returnKeyType = UIReturnKeyType.next
        tfUsername!.clearButtonMode = UITextField.ViewMode.whileEditing
        tfUsername!.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        tfUsername!.delegate = self
        Utils.addLineToView(view: tfUsername!, position:.LINE_POSITION_BOTTOM, color: UIColor.black, width: Double(Constant.BORDER_LINE_HEIGHT))
        
        let ivUsername = UIView(frame: iconFrame)
        let imvUsername = UIImageView();
        imvUsername.image = #imageLiteral(resourceName: "ic_user20pt")
        imvUsername.frame = CGRect(x: xIcon, y: yIcon, width: iconSize, height: iconSize)
        ivUsername.addSubview(imvUsername)
        tfUsername!.leftViewMode  = .always
        tfUsername!.leftView = ivUsername
        self.view.addSubview(tfUsername!)
        
        tfUserCode =  UITextField(frame: tfFrameUsercode)
        //        tfUserCode!.layer.borderWidth = Constant.BORDER_LINE_HEIGHT
        //        tfUserCode!.layer.borderColor = UIColor.black.cgColor
        //        tfUserCode!.layer.cornerRadius = Constant.BORDER_RADIUS
        
        tfUserCode!.setLeftPaddingPoints(paddingLeft)
        tfUserCode!.tag = 0
        tfUserCode?.center.x = self.view.center.x
        tfUserCode!.placeholder = "Mã tài khoản"
        tfUserCode!.font = UIFont.systemFont(ofSize: Constant.FONT_SIZE)
        tfUserCode!.autocorrectionType = UITextAutocorrectionType.no
        tfUserCode!.keyboardType = UIKeyboardType.default
        tfUserCode!.returnKeyType = UIReturnKeyType.next
        tfUserCode!.clearButtonMode = UITextField.ViewMode.whileEditing
        tfUserCode!.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        tfUserCode!.delegate = self
        Utils.addLineToView(view: tfUserCode!, position:.LINE_POSITION_BOTTOM, color: UIColor.black, width: Double(Constant.BORDER_LINE_HEIGHT))
        
        let ivUsercode = UIView(frame: iconFrame)
        let imvUsercode = UIImageView();
        imvUsercode.image = #imageLiteral(resourceName: "ic_usercode20pt")
        imvUsercode.frame = CGRect(x: xIcon, y: yIcon, width: iconSize, height: iconSize)
        ivUsercode.addSubview(imvUsercode)
        tfUserCode!.leftViewMode  = .always
        tfUserCode!.leftView = ivUsercode
        self.view.addSubview(tfUserCode!)
        
        btnLogin = UIButton(frame: tfFrameBtnLogin)
        btnLogin!.center.x = self.view.center.x
        //btnLogin!.layer.borderWidth = Constant.BORDER_LINE_HEIGHT
        //btnLogin!.layer.borderColor = UIColor.black.cgColor
        btnLogin!.layer.cornerRadius = Constant.BORDER_RADIUS
        btnLogin!.setTitle("Đăng nhập", for: .normal)
        btnLogin!.setTitleColor(UIColor.white, for: .normal)
        btnLogin!.backgroundColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR)
        btnLogin!.tag = 3
        btnLogin!.addTarget(self, action: #selector(btnLoginAction), for: .touchUpInside)
        self.view.addSubview(btnLogin!)
        
        let imgLogo = UIImageView();
        imgLogo.image = #imageLiteral(resourceName: "lg_login")
        imgLogo.frame = CGRect(x: 0, y:Int(screenHeight / 2) - Int(tfHeight * 2 + 150), width: 150, height: 150)
        imgLogo.center.x = self.view.center.x
        self.view.addSubview(imgLogo)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = UserDefaults.standard.string(forKey: User.ACCOUNT_CODE){
            tfUserCode?.text = UserDefaults.standard.string(forKey: User.ACCOUNT_CODE)
        }
    }
    
    @objc func btnLoginAction(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        if btnsendtag.tag == 3 {
            if(tfUserCode?.text == "" || tfUsername?.text == "" || tfPassword?.text == ""){
                self.view.makeToast("Vui lòng điền mã tài khoản, tên đăng nhập và mật khẩu", duration: 2.0, position: .center)
            }else{
                Utils.loading(self.view, startAnimate: true)
                RequestManager.login(userCode: (tfUserCode?.text)!, userName: (tfUsername?.text)!, password: (tfPassword?.text)!, completionHandler: {(status, msg) -> Void in
                    if(status){
                        if let result = msg.dictionary{
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
                                                    UserDefaults.standard.set(self.tfUsername?.text, forKey: User.USER_NAME)
                                                    
                                                    //save player id to server
                                                    
                                                    let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                                                    if let playerID = status.subscriptionStatus.userId{
                                                        RequestManager.setPlayerID(userID: (result["idNhanVien"]?.string)!, playerID: playerID, completionHandler: {(status, msg) -> Void in})
                                                    }
                                                    
                                                    
                                                    self.dismiss(animated: true, completion: nil)
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
                    }else{
                        if(msg.string == "timeout"){
                            Utils.loading(self.view, startAnimate: false)
                            self.view.makeToast("Lỗi kết nối. Bạn vui lòng thử lại!", duration: 2.0, position: .center)
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
