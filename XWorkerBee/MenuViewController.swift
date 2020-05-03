//
//  MenuViewController.swift
//  XWorkerBee
//
//  Created by Chan on 3/27/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index: Int32)
}

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var btnCloseMenu: UIButton!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblJobTitle: UILabel!
    @IBOutlet weak var lblUserCode: UILabel!
    
    @IBOutlet weak var vMenu: UIView!
    
    @IBOutlet weak var tbMenuItem: UITableView!
    var btnMenu: UIButton!
    var delegate: SlideMenuDelegate?
    @IBOutlet weak var btnCloseMenuOverlay: UIButton!
    
    var menuList = [MenuModel]()
    private var countView: Int = 0
    private var arr: [Dictionary<String,Any>] = [Dictionary<String,Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnCloseMenu.setImage(#imageLiteral(resourceName: "ic_close30pt-1"), for: .normal)
        
        tbMenuItem.delegate = self
        tbMenuItem.dataSource = self
        tbMenuItem.tableFooterView = UIView()
        tbMenuItem.isScrollEnabled = true
        
        let m1 = MenuModel(isActived: false,icon: #imageLiteral(resourceName: "ic_checkinout_white"), title: "Chấm công", identifier: Menu.CHAM_CONG_MENU)
        let m2 = MenuModel(isActived: false,icon: #imageLiteral(resourceName: "ic_dayoff_white"), title: "Xin nghỉ phép", identifier: Menu.XIN_NGHI_PHEP_MENU)
        let m3 = MenuModel(isActived: false,icon: #imageLiteral(resourceName: "ic_late_white"), title: "Xin đi trễ, về sớm", identifier: Menu.XIN_DI_TRE_VE_SOM_MENU)
        let m4 = MenuModel(isActived: false,icon: #imageLiteral(resourceName: "ic_report_white"), title: "Báo cáo", identifier: Menu.BAO_CAO_MENU)
        let m5 = MenuModel(isActived: false,icon: #imageLiteral(resourceName: "ic_bell1"), title: "Nhắc nhở", identifier: Menu.NHAC_NHO_MENU)
        let m6 = MenuModel(isActived: false,icon: #imageLiteral(resourceName: "ic_changepass_white"), title: "Đổi mật khẩu", identifier: Menu.DOI_MAT_KHAU)
        let m7 = MenuModel(isActived: false,icon: #imageLiteral(resourceName: "ic_logout_white"), title: "Đăng xuất", identifier: Menu.DANG_XUAT_MENU)
        
        menuList.append(m1)
        menuList.append(m2)
        menuList.append(m3)
        menuList.append(m4)
        menuList.append(m5)
        menuList.append(m6)
        menuList.append(m7)
        
//        if let identifier = UserDefaults.standard.string(forKey: User.MENU_SELECTED){
//            self.menuList.filter{ $0.identifier == identifier}.first?.isActived = true
//            self.menuList.filter{ $0.identifier != identifier}.first?.isActived = false
//        }
        
        self.tbMenuItem.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        checkViewedNotification()
        
        if let _ = UserDefaults.standard.string(forKey: User.USER_ID){
            
            switch UIDevice.current.userInterfaceIdiom{
            case .phone:
                vMenu.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.75)
            case .pad:
                vMenu.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.4)
            case .unspecified:
                break
            case .tv: break
            case .carPlay: break
            }
            
            lblFullName.text = UserDefaults.standard.string(forKey: User.USER_FULL_NAME)
            lblUserCode.text = "Mã NV: " + UserDefaults.standard.string(forKey: User.USER_CODE)!
            lblJobTitle.text = "Chức vụ: " + UserDefaults.standard.string(forKey: User.USER_JOB_TITLE)!
            
            Alamofire.request(UserDefaults.standard.string(forKey: User.USER_AVATAR)!).responseData { response in
                if let catPicture = response.result.value {
                    self.imgAvatar.image = nil
                    self.imgAvatar.image = UIImage(data: catPicture)
                    self.imgAvatar.contentMode = .scaleAspectFit
                    //self.imgAvatar.backgroundColor = UIColor.gray
                    //self.imgAvatar.layer.borderWidth = 1.0
                    //self.imgAvatar.layer.masksToBounds = false
                    //self.imgAvatar.layer.borderColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR).cgColor
                    //self.imgAvatar.layer.cornerRadius = self.imgAvatar.frame.size.height / 2
                    //self.imgAvatar.clipsToBounds = true
                    Utils.setupHexagonImageView(imageView: self.imgAvatar)
                }
            }
        }
    }
    private func checkViewedNotification(){
        self.getNotificationList { (arrtemp) -> [Dictionary<String, Any>] in
            for i in arrtemp {
                
                if i["viewed"] as! Int == 1 {
                    
                }else {
                    self.countView += 1
                    self.tbMenuItem.reloadData()
                }
            }
            return arrtemp
        }
    }
    private func getNotificationList(completion: @escaping ([Dictionary<String,Any>]) -> [Dictionary<String,Any>]){
        self.arr.removeAll()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.menuList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell") as! MenuTableViewCell
        cell.selectionStyle = .none
        cell.lblMenuTitle.text = item.title
        cell.imgMenuIcon.image = item.icon
        
        if(indexPath.row == 4){
//            let notifyNumUnread = DataManager().getNotifyListNotYetView()
            //old code: replace self.countView = notifyNumUnread
            if(self.countView > 0){
//                cell.lblBadge.text = String(notifyNumUnread)
                cell.lblBadge.text = String(self.countView)
                cell.lblBadge.isHidden = false
            }else{
                cell.lblBadge.isHidden = true
            }
        }else{
            cell.lblBadge.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let menuItemSelect = self.menuList[indexPath.row]
        
        //close drawer menu
        btnCloseMenuOverlay.sendActions(for: .touchUpInside)
        
        if(!menuItemSelect.isActived){
            
            //self.menuList.filter{ $0.isActived == true}.first?.isActived = false
            //self.menuList.filter{ $0.identifier == menuItemSelect.identifier}.first?.isActived = true
            
//            if(menuItemSelect.identifier != Menu.DANG_XUAT_MENU)
//            {
//                UserDefaults.standard.set(menuItemSelect.identifier, forKey: User.MENU_SELECTED)
//            }
            
            if(menuItemSelect.identifier == Menu.CHAM_CONG_MENU){
                let mvc = storyBoard.instantiateViewController(withIdentifier: menuItemSelect.identifier) as! TimePickingViewController
                self.navigationController?.pushViewController(mvc, animated: true)
            }
            
            if(menuItemSelect.identifier == Menu.XIN_NGHI_PHEP_MENU){
                let dovc = storyBoard.instantiateViewController(withIdentifier: menuItemSelect.identifier) as! DayOffViewController
                self.navigationController?.pushViewController(dovc, animated: true)
            }
            
            if(menuItemSelect.identifier == Menu.XIN_DI_TRE_VE_SOM_MENU){
                let dovc = storyBoard.instantiateViewController(withIdentifier: menuItemSelect.identifier) as! LateViewController
                self.navigationController?.pushViewController(dovc, animated: true)
            }
            
            if(menuItemSelect.identifier == Menu.BAO_CAO_MENU){
                let dovc = storyBoard.instantiateViewController(withIdentifier: menuItemSelect.identifier) as! ReportViewController
                self.navigationController?.pushViewController(dovc, animated: true)
            }
            
            if(menuItemSelect.identifier == Menu.NHAC_NHO_MENU){
                let dovc = storyBoard.instantiateViewController(withIdentifier: menuItemSelect.identifier) as! NotificationViewController
                self.navigationController?.pushViewController(dovc, animated: true)
            }
            
            if(menuItemSelect.identifier == Menu.DOI_MAT_KHAU){
                let dovc = storyBoard.instantiateViewController(withIdentifier: menuItemSelect.identifier) as! ChangePassViewController
                self.navigationController?.pushViewController(dovc, animated: true)
            }
            
            //logout click
            if(menuItemSelect.identifier == Menu.DANG_XUAT_MENU){
                
                let refreshAlert = UIAlertController(title: "Đăng xuất", message: "Bạn có thật sự muốn đăng xuất?", preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Đồng ý", style: .default, handler: { (action: UIAlertAction!) in
                    
                   self.logout(identifier: menuItemSelect.identifier, storyBoard: storyBoard)
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "Huỷ", style: .cancel, handler: { (action: UIAlertAction!) in
                }))
                
                self.present(refreshAlert, animated: true, completion: nil)
                
            }
        }
    }
    
    func logout(identifier: String, storyBoard: UIStoryboard){
        //UserDefaults.standard.set(identifier, forKey: User.MENU_SELECTED)
        
        Utils.logout()
        
        let timeVC = storyBoard.instantiateViewController(withIdentifier: Menu.CHAM_CONG_MENU) as! TimePickingViewController
        let nav = UINavigationController(rootViewController: timeVC)
        
        
        //UIApplication.shared.keyWindow?.rootViewController?.navigationController?.pushViewController(timeVC, animated: true)
        self.parent?.navigationController?.pushViewController(timeVC, animated: true)
        
       // UIApplication.shared.keyWindow?.rootViewController?.present(nav, animated: true, completion: nil)
        
        //open login view controller
        let lvc = storyBoard.instantiateViewController(withIdentifier: identifier) as! LoginViewController
        lvc.modalPresentationStyle = .fullScreen
        UIApplication.shared.keyWindow?.rootViewController!.present(lvc, animated: true, completion: nil)
    }
    
  
    
    @objc func tapCloseMenu(sender: UIButton){
        btnMenu.tag = 0
        btnMenu.isHidden = false
        if(self.delegate != nil){
            var index = Int32(sender.tag)
            if(sender == self.btnCloseMenuOverlay){
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width:
                UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
        }, completion: {(finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
    
    @IBAction func btnCloseMenuAction(_ sender: UIButton) {
        btnMenu.tag = 0
        btnMenu.isHidden = false
        if(self.delegate != nil){
            var index = Int32(sender.tag)
            if(sender == self.btnCloseMenuOverlay){
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width:
                UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
        }, completion: {(finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        btnMenu.tag = 0
        btnMenu.isHidden = false
        if(self.delegate != nil){
            var index = Int32(sender.tag)
            if(sender == self.btnCloseMenuOverlay){
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width:
                UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
        }, completion: {(finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
    
    
    
    
}
