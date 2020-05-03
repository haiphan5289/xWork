//
//  BaseViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import UserNotifications

class BaseViewController: UIViewController, SlideMenuDelegate {
    var coreData: DataManager = DataManager()
    var arCoreData: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.showBadge), name: .showBadge, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
//        arCoreData = coreData.getNotifyListLocal()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        //        let topViewController : UIViewController = self.navigationController!.topViewController!
        //        print("View Controller is : \(topViewController) \n", terminator: "")
        //        switch(index){
        //        case 0:
        //            print("Home\n", terminator: "")
        //            self.openViewControllerBasedOnIdentifier(indentifier)
        //            break
        //        case 1:
        //            print("Play\n", terminator: "")
        //
        //            self.openViewControllerBasedOnIdentifier("PlayVC")
        //
        //            break
        //        default:
        //            print("default\n", terminator: "")
        //        }
    }
    
    func scheduleNotificationStaff(date: Date, title: String, des: String){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
//        content.title = "Nhắc nhở chấm công: \(title)"
        content.title = title
        content.body = des
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        let day = Calendar.current.component(.day, from: date)
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        var dateComponents = DateComponents()
        dateComponents.minute = minute
        dateComponents.hour = hour
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    func detecNextSchedule(){
        self.arCoreData.removeAll()
        self.arCoreData = coreData.getNotifyListLocal()
        RequestManager.determineSchedule(userId: UserDefaults.standard.string(forKey: User.USER_ID) ?? "", completionHandler: {(status, msg) -> Void in
            Utils.loading(self.view, startAnimate: false)
            if(status){
                do {
                    if let jsonDic = msg.dictionaryObject {
                        let data = try JSONSerialization.data(withJSONObject: jsonDic, options: .prettyPrinted)
                        do {
                            let json = try JSONDecoder().decode(NextScheduleOfStaff.self, from: data)
                            if json.tieuDe.isEmpty {
                            } else {
                                if self.arCoreData.contains(json.gio) {
                                    
                                } else {
                                    self.scheduleNotificationStaff(date: json.gio.convertToDate(text: json.gio),
                                                                   title: json.tieuDe,
                                                                   des: json.noiDung)
                                    self.coreData.addNotifyLocal(date: json.gio)
                                }
                            }
                            
                        }catch let err as Error {
                            print(err.localizedDescription)
                        }
                    } else {
                        self.removeSchedulePush()
                    }
                } catch let err as Error {
                    print(err.localizedDescription)
                }
            }
        })
    }
    func removeSchedulePush(){
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
    func openViewControllerBasedOnIdentifier(_ strIdentifier:String){
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        
        let topViewController : UIViewController = self.navigationController!.topViewController!
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            print("Same VC")
        } else {
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    func addSlideMenuButton(allViewed: Bool, countNotView: Int){
        let btnShowMenu = UIButton(type: UIButton.ButtonType.system)
        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControl.State())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
        
        //let backButton = UIBarButtonItem(title: "", style: .plain, target: navigationController, action: nil)
        //self.navigationItem.leftBarButtonItem = backButton
        
        //set notification right bar item menu
        let viewRightBt: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let notiMenu = UIButton(type: .custom)
        notiMenu.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        viewRightBt.addSubview(notiMenu)
        let count: UILabel = UILabel()
        count.frame = CGRect(x: 20, y: 0, width: 20, height: 20)
        count.textAlignment = .center
        count.textColor = .white
        count.font = UIFont.systemFont(ofSize: 12)
        count.layer.cornerRadius = 10
        count.clipsToBounds = true
        viewRightBt.addSubview(count)
        if allViewed {
            notiMenu.setImage(#imageLiteral(resourceName: "ic_bell"), for: .normal)
            count.backgroundColor = .red
            count.text = String(countNotView)
        } else {
            notiMenu.setImage(#imageLiteral(resourceName: "ic_bell1"), for: .normal)
            count.backgroundColor = .clear
            count.text = nil
        }
        notiMenu.addTarget(self, action: #selector(BaseViewController.openNotificationViewByMenu), for: .touchUpInside)
        let rightBarBtnUser = UIBarButtonItem(customView: viewRightBt)
        self.navigationItem.rightBarButtonItem = rightBarBtnUser
    }
    
    @objc func openNotificationViewByMenu() {
        //if let identifierMenuActived = UserDefaults.standard.string(forKey: User.MENU_SELECTED){
        //if(identifierMenuActived != Menu.NHAC_NHO_MENU){
        //set menu is actived
        //UserDefaults.standard.set(Menu.NHAC_NHO_MENU, forKey: User.MENU_SELECTED)
        //open view by menu
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let dovc = storyBoard.instantiateViewController(withIdentifier: Menu.NHAC_NHO_MENU) as! NotificationViewController
        self.navigationController?.pushViewController(dovc, animated: true)
        //}
        //}
    }
    
//    @objc func applicationDidBecomeActive(){
//        
//        let currentAppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
//        let currentAppString = currentAppVersion?.replacingOccurrences(of: ".", with: "", options: .literal, range: nil)
//        let currentAppInt = Int(currentAppString!)
//        
//        RequestManager.getVersion(completionHandler: {(status, msg) -> Void in
//            if(status){
//                if let result = msg.dictionary{
//                    let versionServer = result["IOS"]?.string
//                    let versionServerString = versionServer?.replacingOccurrences(of: ".", with: "", options: .literal, range: nil)
//                    if let versionServerInt = Int(versionServerString!){
//                        if(currentAppInt! < versionServerInt){
//                            let alertMessage = "Vui lòng cập nhật phiên bản mới"
//                            let alert = UIAlertController(title: "Cập nhật ứng dụng", message: alertMessage, preferredStyle: UIAlertController.Style.alert)
//                            
//                            let okBtn = UIAlertAction(title: "Cập nhật", style: .default, handler: {(_ action: UIAlertAction) -> Void in
//                                if let url = URL(string: "itms-apps://itunes.apple.com/vn/app/xworkerbee/id1452976746"),
//                                    UIApplication.shared.canOpenURL(url){
//                                    if #available(iOS 10.0, *) {
//                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                                    } else {
//                                        UIApplication.shared.openURL(url)
//                                    }
//                                }
//                            })
//                            alert.addAction(okBtn)
//                            self.present(alert, animated: true, completion: nil)
//                        } else {
//                        }
//                    }
//                }
//            }
//        })
//    }
    
    //    @objc func didBecomeActive() {
    //        if let identifierMenuActived = UserDefaults.standard.string(forKey: User.MENU_SELECTED){
    //            if(identifierMenuActived != Menu.CHAM_CONG_MENU){
    //                //set menu is actived
    //                UserDefaults.standard.set(Menu.CHAM_CONG_MENU, forKey: User.MENU_SELECTED)
    //                //open view by menu
    //                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    //                let dovc = storyBoard.instantiateViewController(withIdentifier: Menu.CHAM_CONG_MENU) as! TimePickingViewController
    //                self.navigationController?.pushViewController(dovc, animated: true)
    //            }
    //        }
    //    }
    
    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 22), false, 0.0)
        
        UIColor.black.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 10, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 30, height: 1)).fill()
        
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 4, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 18, width: 30, height: 1)).fill()
        
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return defaultMenuImage;
    }
    
    @objc func showBadge() {
        Utils.showBadgeNumber(navItem: self.navigationItem, index: 0)
    }
    
    @objc func onSlideMenuButtonPressed(_ sender : UIButton){
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1);
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
        
        let menuVC : MenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChild(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
        }, completion:nil)
    }
}
