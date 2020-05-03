//
//  DayOffViewController.swift
//  XWorkerBee
//
//  Created by Chan on 2/8/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit
import SwiftyJSON
import DatePickerDialog
import DropDown
import Toast_Swift
import Firebase

class DayOffViewController: BaseViewController, UITextFieldDelegate, UITextViewDelegate {
    
    //var v1,v2: UIView!
    //var btnDayOff: UIButton!
    //var lDate: UILabel!
    //var tfReason: UITextField!
    
    
    @IBOutlet weak var labelFromDate: UILabel!
    @IBOutlet weak var vOption: UIView!
    @IBOutlet weak var vFromDate: UIView!
    @IBOutlet weak var vToDate: UIView!
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var vReason: UIView!
    @IBOutlet weak var lFromDate: UILabel!
    @IBOutlet weak var lToDate: UILabel!
    @IBOutlet weak var lReason: UILabel!
    @IBOutlet weak var btnDayOff: UIButton!
    @IBOutlet weak var tfNoiDung: UITextView!
    @IBOutlet weak var v: UIView!
    @IBOutlet weak var scrollV: UIScrollView!
    @IBOutlet weak var btnOneDay: UIButton!
    @IBOutlet weak var btnManyDay: UIButton!
    @IBOutlet weak var lblOneDay: UILabel!
    @IBOutlet weak var lblManyDay: UILabel!
    @IBOutlet weak var btnScheduleFullDay: UIButton!
    @IBOutlet weak var btnScheduleOff: UIButton!
    @IBOutlet weak var vSelectSchedule: UIView!
    @IBOutlet weak var lblChonCa: UILabel!
    
    let dropDown = DropDown()
    
    var reasonNames = [String]()
    var reasonIDs = [String]()
    var reasonIDSelected: String?
    
    var fromDate: Date?
    var toDate: Date?
    
    var offOneDay: Bool = true
    var offScheduleDay: Bool = true
    private var countView: Int = 0
    private var arr: [Dictionary<String,Any>] = [Dictionary<String,Any>]()
    let dropDownSchedule = DropDown()
    var nameSchedule = [String]()
    var nameIdSchedule = [String]()
    var nameIdSelect: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.tfNoiDung.delegate = self
        self.tfNoiDung.returnKeyType = .done
        
        
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
        //NotificationCenter.default.addObserver(self, selector: #selector(DayOffViewController.showBadgeAtDayOffVC), name: .showBadgeAtDayOffVC, object: nil)
        
        vOption.layer.cornerRadius = Constant.BORDER_RADIUS
        vFromDate.layer.cornerRadius = Constant.BORDER_RADIUS
        vToDate.layer.cornerRadius = Constant.BORDER_RADIUS
        vReason.layer.cornerRadius = Constant.BORDER_RADIUS
        vContent.layer.cornerRadius = Constant.BORDER_RADIUS
        vSelectSchedule.layer.cornerRadius = Constant.BORDER_RADIUS
        
        self.vFromDate.isHidden = false
        self.vToDate.isHidden = true
        self.labelFromDate.text = "Ngày nghỉ: "
        setupAnalytic()
        checkViewedNotification()
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenAppFromBG),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        //detect next schedule
//        self.detecNextSchedule()
    }
    
    @objc func handleOpenAppFromBG(){
        checkViewedNotification()
//        self.detecNextSchedule()
    }
    private func setupAnalytic() {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(title ?? "")",
            AnalyticsParameterItemName: title ?? "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    
    @IBAction func btnOneDayAction(_ sender: Any) {
        if(!offOneDay){
            offOneDay = true
            btnOneDay.setImage(#imageLiteral(resourceName: "ic_radio_check"), for: .normal)
            btnManyDay.setImage(#imageLiteral(resourceName: "ic_radio_uncheck"), for: .normal)
            self.vFromDate.isHidden = false
            self.vToDate.isHidden = true
            self.labelFromDate.text = "Ngày nghỉ: "
            self.lFromDate.text = ""
            self.lToDate.text = ""
            self.tfNoiDung.text = ""
            self.lReason.text = ""
            self.fromDate = nil
            self.toDate = nil
            self.lblChonCa.text = ""
        }
    }
    
    @IBAction func btnManyDayAction(_ sender: Any) {
        if(offOneDay){
            offOneDay = false
            btnOneDay.setImage(#imageLiteral(resourceName: "ic_radio_uncheck"), for: .normal)
            btnManyDay.setImage(#imageLiteral(resourceName: "ic_radio_check"), for: .normal)
            self.vFromDate.isHidden = false
            self.vToDate.isHidden = false
            self.labelFromDate.text = "Từ ngày: "
            self.lFromDate.text = ""
            self.lToDate.text = ""
            self.tfNoiDung.text = ""
            self.lReason.text = ""
            self.fromDate = nil
            self.toDate = nil
            self.lblChonCa.text = ""
        }
    }
    
    @IBAction func btnScheduleFullDayAction(_ sender: UIButton) {
        self.checkButtonScheduleOnOff()
    }
    @IBAction func btnScheduleOffAction(_ sender: Any) {
        self.checkButtonScheduleOnOff()
    }
    @IBAction func tapViewScheduleFullDay(_ sender: UITapGestureRecognizer) {
        self.checkButtonScheduleOnOff()
    }
    @IBAction func tapViewScheduleOff(_ sender: UITapGestureRecognizer) {
        self.checkButtonScheduleOnOff()
    }
    private func checkFromDateToDate (fromDate: String, toDate: String){
            if toDate != "" {
                self.getListScheduleStaff(fromDate: fromDate, toDate: toDate)
            } else {
                self.getListScheduleStaff(fromDate: fromDate, toDate: fromDate)
            }

    }
    private func getListScheduleStaff(fromDate: String, toDate: String){
        self.nameSchedule.removeAll()
        self.nameIdSchedule.removeAll()
        Utils.loading(self.view, startAnimate: true)
        RequestManager.listScheduleStaff(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, fromDate: fromDate, toDate: toDate) { (status, msg) -> Void in
            Utils.loading(self.view, startAnimate: false)
            if(status){
                if let result = msg.array {
                    for (_, item) in result.enumerated() {
                        let name = item["TenCa"].string!
                        let id = item["idCa"].string!
                        self.nameSchedule.append(name)
                        self.nameIdSchedule.append(id)
                    }
                }
                self.dropDownSchedule.dataSource = self.nameSchedule
                guard let firstSchedule = self.nameSchedule.first, let firstIDSchedule = self.nameIdSchedule.first else { return }
                self.lblChonCa.text = firstSchedule
                self.nameIdSelect = firstIDSchedule
            }
        }
    }
    
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
    
    //    @objc func showBadgeAtDayOffVC() {
    //        Utils.showBadgeNumber(navItem: self.navigationItem, index: 0)
    //    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        Utils.showBadgeNumber(navItem: self.navigationItem, index: 0)
        
        //show notification number badge
        //        NotificationCenter.default.post(name: .showBadgeAtNotificationVC, object: nil)
        //
        //        //set notification right bar item menu
        //        let notiMenu = UIButton(type: .custom)
        //        notiMenu.setImage(#imageLiteral(resourceName: "ic_bell"), for: .normal)
        //        notiMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        //        notiMenu.addTarget(self, action: #selector(DayOffViewController.openNotificationViewByMenu), for: .touchUpInside)
        //        let rightBarBtnUser = UIBarButtonItem(customView: notiMenu)
        //        self.navigationItem.setRightBarButtonItems([rightBarBtnUser], animated: true)
        
        
        if let _ = UserDefaults.standard.string(forKey: User.COMPANY_NAME){
            
            if(offOneDay){
                self.vFromDate.isHidden = false
                self.vToDate.isHidden = true
                self.labelFromDate.text = "Ngày nghỉ: "
            }else{
                self.vFromDate.isHidden = false
                self.vToDate.isHidden = false
                self.labelFromDate.text = "Từ ngày: "
            }
            if offScheduleDay {
                self.vSelectSchedule.isHidden = true
            } else {
                self.vSelectSchedule.isHidden = false
            }
            
            
            
            //setupNavigationBar(title: UserDefaults.standard.string(forKey: User.COMPANY_NAME)!)
            
            //Utils.addLineToView(view: lFromDate, position:.LINE_POSITION_BOTTOM, color: UIColor.black, width: Double(Constant.BORDER_LINE_HEIGHT))
            //Utils.addLineToView(view: lToDate, position:.LINE_POSITION_BOTTOM, color: UIColor.black, width: Double(Constant.BORDER_LINE_HEIGHT))
            //Utils.addLineToView(view: lReason, position:.LINE_POSITION_BOTTOM, color: UIColor.black, width: Double(Constant.BORDER_LINE_HEIGHT))
            
            //            //lFromDate.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            //            lFromDate!.layer.borderWidth = Constant.BORDER_LINE_HEIGHT
            //            lFromDate!.layer.borderColor = UIColor.black.cgColor
            //            lFromDate!.layer.cornerRadius = Constant.BORDER_RADIUS
            //
            //            //lToDate.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            //            lToDate!.layer.borderWidth = Constant.BORDER_LINE_HEIGHT
            //            lToDate!.layer.borderColor = UIColor.black.cgColor
            //            lToDate!.layer.cornerRadius = Constant.BORDER_RADIUS
            //
            //            //lReason.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            //            lReason!.layer.borderWidth = Constant.BORDER_LINE_HEIGHT
            //            lReason!.layer.borderColor = UIColor.black.cgColor
            //            lReason!.layer.cornerRadius = Constant.BORDER_RADIUS
            //
            //            tfNoiDung!.layer.borderWidth = Constant.BORDER_LINE_HEIGHT
            //            tfNoiDung!.layer.borderColor = UIColor.black.cgColor
            //            tfNoiDung!.layer.cornerRadius = Constant.BORDER_RADIUS
            //            tfNoiDung.borderStyle = .none
            //            tfNoiDung.tag = 0
            //            tfNoiDung.returnKeyType = UIReturnKeyType.done
            //            tfNoiDung.delegate = self
            //            tfNoiDung.setLeftPaddingPoints(5)
            //            tfNoiDung.setRightPaddingPoints(5)
            //            //Utils.addLineToView(view: tfNoiDung, position:.LINE_POSITION_BOTTOM, color: UIColor.black, width: Double(Constant.BORDER_LINE_HEIGHT))
            
            
            let tapFromDate = UITapGestureRecognizer(target: self, action: #selector(DayOffViewController.selectFromDate))
            lFromDate.isUserInteractionEnabled = true
            lFromDate.addGestureRecognizer(tapFromDate)
            
            let tapToDate = UITapGestureRecognizer(target: self, action: #selector(DayOffViewController.selectToDate))
            lToDate.isUserInteractionEnabled = true
            lToDate.addGestureRecognizer(tapToDate)
            
            let tapReason = UITapGestureRecognizer(target: self, action: #selector(DayOffViewController.selectReason))
            vReason.isUserInteractionEnabled = true
            vReason.addGestureRecognizer(tapReason)
            
            let tapOneDay = UITapGestureRecognizer(target: self, action: #selector(DayOffViewController.oneDaySelect))
            lblOneDay.isUserInteractionEnabled = true
            lblOneDay.addGestureRecognizer(tapOneDay)
            
            let tapManyDay = UITapGestureRecognizer(target: self, action: #selector(DayOffViewController.manyDaySelect))
            lblManyDay.isUserInteractionEnabled = true
            lblManyDay.addGestureRecognizer(tapManyDay)
            
            btnDayOff!.layer.cornerRadius = Constant.BORDER_RADIUS
            btnDayOff!.tag = 1
            
            dropDown.anchorView = vReason
            getReasons()
            dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                //print("Selected item: \(item) at index: \(index)")
                //print("Selected item: \(item) at index: \(self.reasonIDSelected)")
                self.lReason.text = item
                self.reasonIDSelected = self.reasonIDs[index]
                self.dropDown.hide()
            }
            dropDownSchedule.anchorView = self.vSelectSchedule
            dropDownSchedule.selectionAction = { [unowned self] (index: Int, item: String) in
                //print("Selected item: \(item) at index: \(index)")
                //print("Selected item: \(item) at index: \(self.reasonIDSelected)")
                self.lblChonCa.text = item
                self.nameIdSelect = self.nameIdSchedule[index]
                self.dropDown.hide()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
    
    
    @IBAction func btnDayOffAction(_ sender: Any) {
        
        if(self.offOneDay){
            if(lFromDate.text == ""){
                self.view.makeToast("Vui lòng chọn ngày nghỉ", duration: 2.0, position: .center)
            }else{
                if(lReason.text == ""){
                    self.view.makeToast("Vui lòng chọn lý do nghỉ", duration: 2.0, position: .center)
                }else{
                    if(!self.offScheduleDay){
                        if self.lblChonCa.text == "" {
                            self.view.makeToast("Vui lòng chọn ca", duration: 2.0, position: .center)
                        } else {
                            self.requestScheduleOff()
                        }
                    }else{
                    let alert = UIAlertController(title: "Xin nghỉ phép", message: "Bạn chắc chắn muốn xin nghỉ phép ngày " + self.lFromDate.text! + " ?", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Huỷ", style: UIAlertAction.Style.default, handler: { _ in
                        //Cancel Action
                    }))
                    alert.addAction(UIAlertAction(title: "Đồng ý",
                                                  style: UIAlertAction.Style.default,
                                                  handler: {(_: UIAlertAction!) in
                                                    
                                                    Utils.loading(self.view, startAnimate: true)
                                                    RequestManager.dayOff(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, reasonId: self.reasonIDSelected!, fromDate: self.lFromDate.text!, toDate: self.lFromDate.text!, content: self.tfNoiDung.text!, completionHandler: {(status, msg) -> Void in
                                                        Utils.loading(self.view, startAnimate: false)
                                                        if(status){
                                                            if let result = msg.dictionary{
                                                                let dayOffStatus = result["KetQua"]?.int
                                                                if(dayOffStatus == 1){
                                                                    self.view.makeToast("Xin nghỉ phép thành công", duration: 2.0, position: .center)
                                                                    self.lFromDate.text = ""
                                                                    self.lToDate.text = ""
                                                                    self.lReason.text = ""
                                                                    self.tfNoiDung.text = ""
                                                                    self.fromDate = nil
                                                                    self.lblChonCa.text = ""
                                                                }
                                                                if(dayOffStatus == 2){
                                                                    self.view.makeToast("Bạn đã xin nghỉ phép rồi", duration: 2.0, position: .center)
                                                                    self.lFromDate.text = ""
                                                                    self.lToDate.text = ""
                                                                    self.lReason.text = ""
                                                                    self.tfNoiDung.text = ""
                                                                    self.fromDate = nil
                                                                    self.lblChonCa.text = ""
                                                                }
                                                                if(dayOffStatus == 0){
                                                                    self.view.makeToast("Xin nghỉ phép không thành công", duration: 2.0, position: .center)
                                                                }
                                                            }
                                                        }
                                                    })
                                                    
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                }
            }
            
        }else{
            if(lFromDate.text == "" || lToDate.text == ""){
                self.view.makeToast("Vui lòng chọn ngày nghỉ", duration: 2.0, position: .center)
            }else{
                if(lReason.text == ""){
                    self.view.makeToast("Vui lòng chọn lý do nghỉ", duration: 2.0, position: .center)
                }else {
                    if (!self.offScheduleDay) {
                        if self.lblChonCa.text == "" {
                            self.view.makeToast("Vui lòng chọn ca", duration: 2.0, position: .center)
                        } else {
                            self.requestScheduleOff()
                        }
                    }else{
                    if(self.fromDate != nil && self.toDate != nil){
                        
                        if(self.describeComparison(fromDate: self.fromDate!, toDate: self.toDate!)){
                            
                            let alert = UIAlertController(title: "Xin nghỉ phép", message: "Bạn chắc chắn muốn xin nghỉ phép từ ngày " + self.lFromDate.text! + " đến ngày " + self.lToDate.text! + " ?", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Huỷ", style: UIAlertAction.Style.default, handler: { _ in
                                //Cancel Action
                            }))
                            alert.addAction(UIAlertAction(title: "Đồng ý",
                                                          style: UIAlertAction.Style.default,
                                                          handler: {(_: UIAlertAction!) in
                                                            
                                                            Utils.loading(self.view, startAnimate: true)
                                                            RequestManager.dayOff(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, reasonId: self.reasonIDSelected!, fromDate: self.lFromDate.text!, toDate: self.lToDate.text!, content: self.tfNoiDung.text!, completionHandler: {(status, msg) -> Void in
                                                                Utils.loading(self.view, startAnimate: false)
                                                                if(status){
                                                                    if let result = msg.dictionary{
                                                                        let dayOffStatus = result["KetQua"]?.int
                                                                        if(dayOffStatus == 1){
                                                                            self.view.makeToast("Xin nghỉ phép thành công", duration: 2.0, position: .center)
                                                                            self.lFromDate.text = ""
                                                                            self.lToDate.text = ""
                                                                            self.lReason.text = ""
                                                                            self.tfNoiDung.text = ""
                                                                            self.fromDate = nil
                                                                            self.toDate = nil
                                                                            self.lblChonCa.text = ""
                                                                            self.nameSchedule.removeAll()
                                                                            self.dropDownSchedule.dataSource = self.nameSchedule
                                                                        }
                                                                        if(dayOffStatus == 2){
                                                                            self.view.makeToast("Bạn đã xin nghỉ phép rồi", duration: 2.0, position: .center)
                                                                            self.lFromDate.text = ""
                                                                            self.lToDate.text = ""
                                                                            self.lReason.text = ""
                                                                            self.tfNoiDung.text = ""
                                                                            self.fromDate = nil
                                                                            self.toDate = nil
                                                                            self.lblChonCa.text = ""
                                                                            self.nameSchedule.removeAll()
                                                                            self.dropDownSchedule.dataSource = self.nameSchedule
                                                                        }
                                                                        if(dayOffStatus == 0){
                                                                            self.view.makeToast("Xin nghỉ phép không thành công", duration: 2.0, position: .center)
                                                                        }
                                                                    }
                                                                }
                                                            })
                                                            
                            }))
                            self.present(alert, animated: true, completion: nil)
                            
                            
                        }else{
                            self.view.makeToast("Ngày không hợp lệ. Từ ngày phải nhỏ hơn Đến ngày", duration: 2.0, position: .center)
                        }
                    }
                }
                }}
            
        }
        
    }
    
    private func requestScheduleOff(){
        let alert = UIAlertController(title: "Xin nghỉ phép", message: "Bạn chắc chắn muốn xin nghỉ phép ca " + self.lblChonCa.text! + " ?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Huỷ", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Đồng ý",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
                                        
                                        Utils.loading(self.view, startAnimate: true)
                                        RequestManager.ScheduleOff(idSchedule: self.nameIdSelect!, userId: UserDefaults.standard.string(forKey: User.USER_ID)!, reasonId: self.reasonIDSelected!, fromDate: self.lFromDate.text!, toDate: self.lFromDate.text!, content: self.tfNoiDung.text!, completionHandler: {(status, msg) -> Void in
                                            Utils.loading(self.view, startAnimate: false)
                                            if(status){
                                                if let result = msg.dictionary{
                                                    let dayOffStatus = result["KetQua"]?.int
                                                    if(dayOffStatus == 1){
                                                        self.view.makeToast("Xin nghỉ phép thành công", duration: 2.0, position: .center)
                                                        self.lFromDate.text = ""
                                                        self.lToDate.text = ""
                                                        self.lReason.text = ""
                                                        self.tfNoiDung.text = ""
                                                        self.fromDate = nil
                                                        self.lblChonCa.text = ""
                                                        self.nameSchedule.removeAll()
                                                        self.dropDownSchedule.dataSource = self.nameSchedule
                                                    }
                                                    if(dayOffStatus == 2){
                                                        self.view.makeToast("Bạn đã xin nghỉ phép rồi", duration: 2.0, position: .center)
                                                        self.lFromDate.text = ""
                                                        self.lToDate.text = ""
                                                        self.lReason.text = ""
                                                        self.tfNoiDung.text = ""
                                                        self.fromDate = nil
                                                        self.lblChonCa.text = ""
                                                        self.nameSchedule.removeAll()
                                                        self.dropDownSchedule.dataSource = self.nameSchedule
                                                    }
                                                    if(dayOffStatus == 0){
                                                        self.view.makeToast("Xin nghỉ phép không thành công", duration: 2.0, position: .center)
                                                    }
                                                }
                                            }
                                        })
                                        
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func getReasons(){
        RequestManager.getReasons(completionHandler: {(status, msg) -> Void in
            if(status){
                self.reasonNames.removeAll()
                self.reasonIDs.removeAll()
                if let reasonList = msg.array{
                    for item in reasonList{
                        let reasonItem = item.dictionary
                        self.reasonNames.append(reasonItem!["LyDo"]!.string!)
                        self.reasonIDs.append(reasonItem!["idLyDoNghi"]!.string!)
                    }
                    self.dropDown.dataSource = self.reasonNames
                }
            }
        })
    }
    
    func describeComparison(fromDate: Date, toDate: Date) -> Bool {
        if fromDate < toDate {
            return true
        }else{
            if(fromDate == toDate){
                return true
            }else{
                return false
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Utils.loading(self.view, startAnimate: false)
    }
    
    @objc
    func selectReason(sender:UITapGestureRecognizer) {
        self.dropDown.show()
    }
    
    @objc
    func oneDaySelect(sender:UITapGestureRecognizer) {
        if(!offOneDay){
            offOneDay = true
            btnOneDay.setImage(#imageLiteral(resourceName: "ic_radio_check"), for: .normal)
            btnManyDay.setImage(#imageLiteral(resourceName: "ic_radio_uncheck"), for: .normal)
            self.vFromDate.isHidden = false
            self.vToDate.isHidden = true
            self.labelFromDate.text = "Ngày nghỉ: "
            self.lFromDate.text = ""
            self.lToDate.text = ""
            self.tfNoiDung.text = ""
            self.lReason.text = ""
            self.fromDate = nil
            self.toDate = nil
            self.nameSchedule.removeAll()
            self.dropDownSchedule.dataSource = self.nameSchedule
        }
    }
    
    @objc
    func manyDaySelect(sender:UITapGestureRecognizer) {
        if(offOneDay){
            offOneDay = false
            btnOneDay.setImage(#imageLiteral(resourceName: "ic_radio_uncheck"), for: .normal)
            btnManyDay.setImage(#imageLiteral(resourceName: "ic_radio_check"), for: .normal)
            self.vFromDate.isHidden = false
            self.vToDate.isHidden = false
            self.labelFromDate.text = "Từ ngày: "
            self.lFromDate.text = ""
            self.lToDate.text = ""
            self.tfNoiDung.text = ""
            self.lReason.text = ""
            self.fromDate = nil
            self.toDate = nil
            self.nameSchedule.removeAll()
            self.dropDownSchedule.dataSource = self.nameSchedule
        }
    }
    
    @IBAction func actionChonCa(_ sender: UITapGestureRecognizer) {
        self.dropDownSchedule.show()
    }
    
    
    @objc
    func selectFromDate(sender:UITapGestureRecognizer) {
        let date = Date()
        let datePicker =  DatePickerDialog(locale: Locale(identifier: "vi_VN"))
        datePicker.show("Từ ngày", doneButtonTitle: "Chọn", cancelButtonTitle: "Đóng", defaultDate: date, minimumDate: nil, maximumDate: nil, datePickerMode: .date, callback: { (date) -> Void in
            if let dt = date {
                self.fromDate = dt
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                self.lFromDate.text = formatter.string(from: dt)
                //                if(self.toDate == nil){
                //                    let formatter = DateFormatter()
                //                    formatter.dateFormat = "dd/MM/yyyy"
                //                    self.lFromDate.text = formatter.string(from: dt)
                //                }else{
                //                    if(self.describeComparison(fromDate: self.fromDate!, toDate: self.toDate!)){
                //                        let formatter = DateFormatter()
                //                        formatter.dateFormat = "dd/MM/yyyy"
                //                        self.lFromDate.text = formatter.string(from: dt)
                //                    }else{
                //                        self.view.makeToast("Ngày không hợp lệ. Vui lòng chọn lại")
                //                        self.lFromDate.text = ""
                //                        self.fromDate = nil
                //                    }
                //                }
                self.checkFromDateToDate(fromDate: self.lFromDate.text!, toDate: self.lToDate.text!)
            }
        })
    }
    
    @objc
    func selectToDate(sender:UITapGestureRecognizer) {
        let date = Date()
        let datePicker =  DatePickerDialog(locale: Locale(identifier: "vi_VN"))
        datePicker.show("Đến ngày", doneButtonTitle: "Chọn", cancelButtonTitle: "Đóng", defaultDate: date, minimumDate: nil, maximumDate: nil, datePickerMode: .date, callback: { (date) -> Void in
            if let dt = date {
                self.toDate = dt
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                self.lToDate.text = formatter.string(from: dt)
                //                if(self.fromDate == nil){
                //                    let formatter = DateFormatter()
                //                    formatter.dateFormat = "dd/MM/yyyy"
                //                    self.lToDate.text = formatter.string(from: dt)
                //                }else{
                //                    if(self.describeComparison(fromDate: self.fromDate!, toDate: self.toDate!)){
                //                        let formatter = DateFormatter()
                //                        formatter.dateFormat = "dd/MM/yyyy"
                //                        self.lToDate.text = formatter.string(from: dt)
                //                    }else{
                //                        self.view.makeToast("Ngày không hợp lệ. Vui lòng chọn lại")
                //                        self.lToDate.text = ""
                //                        self.toDate = nil
                //                    }
                //                }
                self.checkFromDateToDate(fromDate: self.lFromDate.text!, toDate: self.lToDate.text!)
            }
        })
    }
    
    @IBAction func btOneDayAction(_ sender: UIButton) {
        offOneDay = true
        btnOneDay.setImage(#imageLiteral(resourceName: "ic_radio_check"), for: .normal)
        btnManyDay.setImage(#imageLiteral(resourceName: "ic_radio_uncheck"), for: .normal)
        self.vFromDate.isHidden = false
        self.vToDate.isHidden = true
        self.labelFromDate.text = "Ngày nghỉ: "
        self.lFromDate.text = ""
        self.lToDate.text = ""
        self.tfNoiDung.text = ""
        self.lReason.text = ""
        self.fromDate = nil
        self.toDate = nil
        self.nameSchedule.removeAll()
        self.dropDownSchedule.dataSource = self.nameSchedule
    }
    
    @IBAction func btManyDayAction(_ sender: UIButton) {
        if(offOneDay){
            offOneDay = false
            btnOneDay.setImage(#imageLiteral(resourceName: "ic_radio_uncheck"), for: .normal)
            btnManyDay.setImage(#imageLiteral(resourceName: "ic_radio_check"), for: .normal)
            self.vFromDate.isHidden = false
            self.vToDate.isHidden = false
            self.labelFromDate.text = "Từ ngày: "
            self.lFromDate.text = ""
            self.lToDate.text = ""
            self.tfNoiDung.text = ""
            self.lReason.text = ""
            self.fromDate = nil
            self.toDate = nil
            self.nameSchedule.removeAll()
            self.dropDownSchedule.dataSource = self.nameSchedule
        }
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            // if self.view.frame.origin.y == 0 {
            //self.view.frame.origin.y -= keyboardSize.height
            self.v.heightConstaint?.constant = UIScreen.main.bounds.height + keyboardSize.height
            self.scrollV.scrollTo(direction: .Bottom)
            //}
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //if self.view.frame.origin.y != 0 {
        // self.view.frame.origin.y = 0
        self.v.heightConstaint?.constant = UIScreen.main.bounds.height + 200
//        self.scrollV.scrollTo(direction: .Bottom)
        // }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
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
extension DayOffViewController {
    private func checkButtonScheduleOnOff() {
        if offScheduleDay {
            self.offScheduleDay = false
            self.vSelectSchedule.isHidden = false
            btnScheduleFullDay.setImage(#imageLiteral(resourceName: "ic_radio_uncheck"), for: .normal)
            btnScheduleOff.setImage(#imageLiteral(resourceName: "ic_radio_check"), for: .normal)
        } else {
            self.offScheduleDay = true
            self.vSelectSchedule.isHidden = true
            btnScheduleFullDay.setImage(#imageLiteral(resourceName: "ic_radio_check"), for: .normal)
            btnScheduleOff.setImage(#imageLiteral(resourceName: "ic_radio_uncheck"), for: .normal)
        }
    }
}
