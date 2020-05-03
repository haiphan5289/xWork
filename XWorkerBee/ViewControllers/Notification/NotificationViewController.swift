//
//  NotificationViewController.swift
//  XWorkerBee
//
//  Created by Chan on 4/10/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit

class NotificationViewController:  BaseViewController{
    
    @IBOutlet weak var vbg: UIView!
    @IBOutlet weak var tb: UITableView!
    
    var arr = [Dictionary<String,Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add slider menu
        self.addSlideMenuButton(allViewed: false, countNotView: 0)
        
        self.vbg.layer.cornerRadius = 10
        
        tb.delegate = self
        tb.dataSource = self
        tb.tableFooterView = UIView()
        tb.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "tbNotificationCell")
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationViewController.reloadNotificationList), name: .showBadgeAtNotificationVC, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenAppFromBG),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
//        self.detecNextSchedule()
    }
    @objc func handleOpenAppFromBG(){
//         self.detecNextSchedule()
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //
    //        //show notification number badge
    //        NotificationCenter.default.post(name: .showBadgeAtNotificationVC, object: nil)
    //
    //        //set notification right bar item menu
    //        let notiMenu = UIButton(type: .custom)
    //        notiMenu.setImage(#imageLiteral(resourceName: "ic_bell"), for: .normal)
    //        notiMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    //        notiMenu.addTarget(self, action: #selector(NotificationViewController.openNotificationViewByMenu), for: .touchUpInside)
    //        let rightBarBtnUser = UIBarButtonItem(customView: notiMenu)
    //        self.navigationItem.setRightBarButtonItems([rightBarBtnUser], animated: true)
    //    }
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
    
        @objc func reloadNotificationList() {
            //self.arr.removeAll()
            //self.arr = DataManager().getNotifyList()
            //self.tb.reloadData()
            getNotificationList()
        }
    
    override func viewWillAppear(_ animated: Bool) {
        //UserDefaults.standard.set(false, forKey: User.SHOW_NOTIFICATION_BADGE_FLAG)
        DataManager().updateAllNotifyViewed()
        Utils.showBadgeNumber(navItem: self.navigationItem, index: 0)
        getNotificationList()
    }
    
//    private func checkViewedNotification(){
//        self.getNotificationList { (arrtemp) -> [Dictionary<String, Any>] in
//            self.addSlideMenuButton(allViewed: false, countNotView: self.countView)
//            self.tb.reloadData()
//            return arrtemp
//        }
//    }
    func getNotificationList(){
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
                                  "viewed": false,
                                  "notification_id": item["notification_id"].string!,
                                  "id": item["id"].string!] as [String : Any]
                        self.arr.append(dc)
                        if(((msg.array?.count)! - 1) == index){
                            listId = listId + item["id"].string!
                        }else{
                            listId = listId + item["id"].string! + "_"
                        }
                    }
                    self.tb.reloadData()
                    self.updateNotificationList(listId: listId)
                }
            }
        })
    }
    
    func updateNotificationList(listId: String){
        RequestManager.updateListNotificationStatus(userID: UserDefaults.standard.string(forKey: User.USER_ID)!, notificationID: listId, completionHandler: {(status, msg) -> Void in
        })
    }
    
    
}

//class NotificationTableViewCell: UITableViewCell{
//    
//    @IBOutlet weak var vNotificationItem: UIView!
//    @IBOutlet weak var lblNotificationDate: UILabel!
//    @IBOutlet weak var lblNotificationCotent: UILabel!
//    
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        let borderWidth = CGFloat(0.3)
//        let borderColor = UITableView().separatorColor?.cgColor
//        
//        vNotificationItem.layer.borderWidth = borderWidth
//        vNotificationItem.layer.borderColor = borderColor
//        lblNotificationCotent.sizeToFit()
//    }
//    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }
//    
//    
//}

extension NotificationViewController:  UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = arr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "tbNotificationCell", for: indexPath) as! NotificationCell
        cell.selectionStyle = .none
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 10
        
        let content = (item["content"] as? String)!
        
        //cell.lblNotificationCotent.attributedText = NSAttributedString(string: content, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        
        let title: String = (item["title"] as? String)!
        //cell.lblNotificationDate.attributedText =  NSAttributedString(string: "Ngày: " + title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        cell.lbNotificationDate.text = title
        cell.lbNotificationContent.text = content
        
        let viewed: Bool = (item["viewed"] as? Bool)!
        if(viewed){
            //had viewed
            cell.lbNotificationDate.font = UIFont.systemFont(ofSize: 13)
            cell.lbNotificationContent.font = UIFont.systemFont(ofSize: 13)
            cell.lbNotificationDate.textColor = UIColor.darkText
            cell.lbNotificationContent.textColor = UIColor.darkText
        }else{
            cell.lbNotificationDate.font = UIFont.boldSystemFont(ofSize: 13)
            cell.lbNotificationContent.font = UIFont.boldSystemFont(ofSize: 13)
            cell.lbNotificationDate.textColor = UIColor.white
            cell.lbNotificationContent.textColor = UIColor.white
        }
    
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        let item = arr[indexPath.row]
//        let title: String = (item["title"] as? String)!
//        let content: String = (item["content"] as? String)!
//        let viewed: Bool = (item["viewed"] as? Bool)!
//
//        //let alert = UIAlertController(title: "Thông báo ngày " + title, message: content, preferredStyle: .alert)
//        //alert.addAction(UIAlertAction(title: "Đóng", style: .default, handler: nil))
//        //self.present(alert, animated: true)
//
////        if(!viewed){
////            let id = item["notification_id"] as? String
////            let updateStatus = DataManager().updateNotifyViewed(id: id!)
////            if(updateStatus){
////                Utils.showBadgeNumber(navItem: self.navigationItem, index: 0)
////
////                self.arr.removeAll()
////                self.arr = DataManager().getNotifyList()
////                self.tb.reloadData()
////
////                //call api update to server
////                //RequestManager.updateNotificationStatus(userID: UserDefaults.standard.string(forKey: User.USER_ID)!, notificationID: id!, completionHandler: {(status, msg) -> Void in})
////            }
////        }
//    }
    
    
    
}
