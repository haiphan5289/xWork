//
//  LateViewController.swift
//  XWorkerBee
//
//  Created by Chan on 3/28/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit
import SwiftyJSON
import DatePickerDialog
import DropDown
import Toast_Swift

class LateViewController: BaseViewController, UITextViewDelegate {
    
    @IBOutlet weak var lblGioValue: UILabel!
    @IBOutlet weak var lblGioTittle: UILabel!
    @IBOutlet weak var vGio: UIView!
    @IBOutlet weak var vNgayXin: UIView!
    @IBOutlet weak var lblNgayXin: UILabelPadding!
    @IBOutlet weak var vLoaiXin: UIView!
    @IBOutlet weak var lblLoaiXin: UILabelPadding!
    @IBOutlet weak var vLyDo: UIView!
    @IBOutlet weak var lblLyDo: UILabelPadding!
    @IBOutlet weak var vNoiDung: UIView!
    @IBOutlet weak var tfNoiDung: UITextView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var v: UIView!
    @IBOutlet weak var scrollV: UIScrollView!
    @IBOutlet weak var vChonCa: UIView!
    @IBOutlet weak var lblChonCa: UILabelPadding!
    
    let dropDownReason = DropDown()
    var reasonNames = [String]()
    var reasonIDs = [String]()
    var reasonIDSelected: String?
    
    let dropDownType = DropDown()
    var typeNames = [String]()
    var typeIDs = [String]()
    var typeIDSelected: String?
    
    var hourValue: String?
    var minuteValue: String?
    
    var lateDate: Date?
    var lateHour: Date?
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
        
        tfNoiDung.delegate = self
        tfNoiDung.returnKeyType = .done
        
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
        //NotificationCenter.default.addObserver(self, selector: #selector(LateViewController.showBadgeAtLateVC), name: .showBadgeAtLateVC, object: nil)
        
        vGio.layer.cornerRadius = Constant.BORDER_RADIUS
        vNgayXin.layer.cornerRadius = Constant.BORDER_RADIUS
        vLoaiXin.layer.cornerRadius = Constant.BORDER_RADIUS
        vLyDo.layer.cornerRadius = Constant.BORDER_RADIUS
        vNoiDung.layer.cornerRadius = Constant.BORDER_RADIUS
        btnSubmit.layer.cornerRadius = Constant.BORDER_RADIUS
        btnSubmit.tag = 1
        vChonCa.layer.cornerRadius = Constant.BORDER_RADIUS
        
        typeNames = ["Xin đi trễ", "Xin về sớm"]
        typeIDs = ["1", "2"]
        self.dropDownType.dataSource = self.typeNames
        checkViewedNotification()
//        self.detecNextSchedule()
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenAppFromBG),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    @objc func handleOpenAppFromBG() {
        checkViewedNotification()
//        self.detecNextSchedule()
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
    //
    //    @objc func showBadgeAtLateVC() {
    //        Utils.showBadgeNumber(navItem: self.navigationItem, index: 0)
    //    }
    //
    override func viewWillAppear(_ animated: Bool) {
        
        Utils.showBadgeNumber(navItem: self.navigationItem, index: 0)
        
        //        //show notification number badge
        //        NotificationCenter.default.post(name: .showBadgeAtNotificationVC, object: nil)
        //
        //        //set notification right bar item menu
        //        let notiMenu = UIButton(type: .custom)
        //        notiMenu.setImage(#imageLiteral(resourceName: "ic_bell"), for: .normal)
        //        notiMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        //        notiMenu.addTarget(self, action: #selector(LateViewController.openNotificationViewByMenu), for: .touchUpInside)
        //        let rightBarBtnUser = UIBarButtonItem(customView: notiMenu)
        //        self.navigationItem.setRightBarButtonItems([rightBarBtnUser], animated: true)
        
        let tapLateDate = UITapGestureRecognizer(target: self, action: #selector(LateViewController.selectLateDate))
        lblNgayXin.isUserInteractionEnabled = true
        lblNgayXin.addGestureRecognizer(tapLateDate)
        
        let tapLateHour = UITapGestureRecognizer(target: self, action: #selector(LateViewController.selectLateHour))
        vGio.isUserInteractionEnabled = true
        vGio.addGestureRecognizer(tapLateHour)
        
        let tapReason = UITapGestureRecognizer(target: self, action: #selector(LateViewController.selectReason))
        vLyDo.isUserInteractionEnabled = true
        vLyDo.addGestureRecognizer(tapReason)
        
        let tapType = UITapGestureRecognizer(target: self, action: #selector(LateViewController.selectType))
        vLoaiXin.isUserInteractionEnabled = true
        vLoaiXin.addGestureRecognizer(tapType)
        
        dropDownReason.anchorView = vLyDo
        getReasonLate()
        dropDownReason.selectionAction = { [unowned self] (index: Int, item: String) in
            //print("Selected item: \(item) at index: \(index)")
            //print("Selected item: \(item) at index: \(self.reasonIDSelected)")
            self.lblLyDo.text = item
            self.reasonIDSelected = self.reasonIDs[index]
            self.dropDownReason.hide()
        }
        
        dropDownType.anchorView = vLoaiXin
        dropDownType.selectionAction = { [unowned self] (index: Int, item: String) in
            //print("Selected item: \(item) at index: \(index)")
            //print("Selected item: \(item) at index: \(self.reasonIDSelected)")
            self.lblLoaiXin.text = item
            self.typeIDSelected = self.reasonIDs[index]
            self.dropDownType.hide()
            
            if(index == 0){
                self.lblGioTittle.text = "Giờ vào:"
            }else{
                self.lblGioTittle.text = "Giờ ra:"
            }
        }
        dropDownSchedule.anchorView = vChonCa
        dropDownSchedule.selectionAction = { [unowned self] (index: Int, item: String) in
            //print("Selected item: \(item) at index: \(index)")
            //print("Selected item: \(item) at index: \(self.reasonIDSelected)")
            self.lblChonCa.text = item
            self.nameIdSelect = self.nameIdSchedule[index]
            self.dropDownType.hide()
        }
    }
    
    
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
    
    private func getListScheduleDayStaff (date: String){
        self.nameSchedule.removeAll()
        self.nameIdSchedule.removeAll()
        Utils.loading(self.view, startAnimate: true)
        RequestManager.listScheduleStaff(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, fromDate: date, toDate: date) { (status, msg) -> Void in
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
                guard let firstSchedule = self.nameSchedule.first, let firstIdSchedule = self.nameIdSchedule.first else { return }
                self.lblChonCa.text = firstSchedule
                self.nameIdSelect = firstIdSchedule
            }
        }
    }
    
    @objc
    func selectLateDate(sender:UITapGestureRecognizer) {
        let date = Date()
        let datePicker =  DatePickerDialog(locale: Locale(identifier: "vi_VN"))
        datePicker.show("Chọn ngày", doneButtonTitle: "Chọn", cancelButtonTitle: "Đóng", defaultDate: date, minimumDate: nil, maximumDate: nil, datePickerMode: .date, callback: { (date) -> Void in
            if let dt = date {
                self.lateDate = date
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                self.lblNgayXin.text = formatter.string(from: dt)
                self.getListScheduleDayStaff(date: self.lblNgayXin.text!)
            }
        })
    }
    
    @objc
    func selectLateHour(sender:UITapGestureRecognizer) {
        let date = Date()
        let datePicker =  DatePickerDialog(locale: Locale(identifier: "vi_VN"))
        datePicker.show("Chọn giờ", doneButtonTitle: "Chọn", cancelButtonTitle: "Đóng", defaultDate: date, minimumDate: nil, maximumDate: nil, datePickerMode: .time, callback: { (date) -> Void in
            if let dt = date {
                self.lateHour = date
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let hourFormatter = DateFormatter()
                hourFormatter.dateFormat = "HH"
                let minuteFormatter = DateFormatter()
                minuteFormatter.dateFormat = "mm"
                self.lblGioValue.text = formatter.string(from: dt)
                self.hourValue = hourFormatter.string(from: dt)
                self.minuteValue = minuteFormatter.string(from: dt)
            }
        })
    }
    
    @objc
    func selectReason(sender:UITapGestureRecognizer) {
        self.dropDownReason.show()
    }
    
    @IBAction func actionChonCa(_ sender: UITapGestureRecognizer) {
        self.dropDownSchedule.show()
    }
    @objc
    func selectType(sender:UITapGestureRecognizer) {
        self.dropDownType.show()
    }
    
    func getReasonLate(){
        RequestManager.getReasonLate(completionHandler: {(status, msg) -> Void in
            if(status){
                self.reasonNames.removeAll()
                self.reasonIDs.removeAll()
                if let reasonList = msg.array{
                    for item in reasonList{
                        let reasonItem = item.dictionary
                        self.reasonNames.append(reasonItem!["LyDo"]!.string!)
                        self.reasonIDs.append(reasonItem!["idLyDoDiTreVeSom"]!.string!)
                    }
                    self.dropDownReason.dataSource = self.reasonNames
                }
            }
        })
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //if self.view.frame.origin.y == 0 {
            //self.view.frame.origin.y -= keyboardSize.height
            self.v.heightConstaint?.constant = UIScreen.main.bounds.height + keyboardSize.height
            self.scrollV.scrollTo(direction: .Bottom)
            //}
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //if self.view.frame.origin.y != 0 {
        //self.view.frame.origin.y = 0
        self.v.heightConstaint?.constant = UIScreen.main.bounds.height + 200
        //}
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func btnSubmitAction(_ sender: Any) {
        
        if(lblNgayXin.text == ""){
            self.view.makeToast("Vui lòng chọn ngày xin đi trễ về sớm", duration: 2.0, position: .center)
        }else{
            if(lblLyDo.text == ""){
                self.view.makeToast("Vui lòng chọn lý do", duration: 2.0, position: .center)
            }else{
                if(lblLoaiXin.text == ""){
                    self.view.makeToast("Vui lòng chọn loại", duration: 2.0, position: .center)
                }else{
                    
                    if(lblGioValue.text == ""){
                        self.view.makeToast("Vui lòng chọn giờ", duration: 2.0, position: .center)
                    } else {
                        if (lblChonCa.text == ""){
                            self.view.makeToast("Vui lòng chọn ca", duration: 2.0, position: .center)
                    }else{
                        
                        let alert = UIAlertController(title: "Xin đi trễ về sớm", message: "Bạn chắc chắn muốn xin đi trễ về sớm ngày " + lblNgayXin.text! + "?", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Huỷ", style: UIAlertAction.Style.default, handler: { _ in
                            //Cancel Action
                        }))
                        alert.addAction(UIAlertAction(title: "Đồng ý",
                                                      style: UIAlertAction.Style.default,
                                                      handler: {(_: UIAlertAction!) in
                                                        
                                                        Utils.loading(self.view, startAnimate: true)
                                                        RequestManager.lateOffSchedule(idShedule: self.nameIdSelect!, userId: UserDefaults.standard.string(forKey: User.USER_ID)!, reasonId: self.reasonIDSelected!, lateDate: self.lblNgayXin.text!, typeLate: self.typeIDSelected!, hour: self.hourValue!, minute: self.minuteValue!, content: self.tfNoiDung.text!, completionHandler: {(status, msg) -> Void in
                                                            Utils.loading(self.view, startAnimate: false)
                                                            if(status){
                                                                if let result = msg.dictionary{
                                                                    let dayOffStatus = result["KetQua"]?.int
                                                                    if(dayOffStatus == 1){
                                                                        self.view.makeToast("Xin đi trễ về sớm thành công", duration: 2.0, position: .center)
                                                                        self.lblNgayXin.text = ""
                                                                        self.lblLoaiXin.text = ""
                                                                        self.lblLyDo.text = ""
                                                                        self.tfNoiDung.text = ""
                                                                        self.lateDate = nil
                                                                        
                                                                        self.lateHour = nil
                                                                        self.hourValue = nil
                                                                        self.minuteValue = nil
                                                                        self.lblGioValue.text = ""
                                                                        self.lblGioTittle.text = ""
                                                                        self.lblChonCa.text = ""
                                                                    }
                                                                    if(dayOffStatus == 2){
                                                                        self.view.makeToast("Bạn đã xin đi trễ về sớm rồi", duration: 2.0, position: .center)
                                                                        self.lblNgayXin.text = ""
                                                                        self.lblLoaiXin.text = ""
                                                                        self.lblLyDo.text = ""
                                                                        self.tfNoiDung.text = ""
                                                                        self.lateDate = nil
                                                                        
                                                                        self.lateHour = nil
                                                                        self.hourValue = nil
                                                                        self.minuteValue = nil
                                                                        self.lblGioValue.text = ""
                                                                        self.lblGioTittle.text = ""
                                                                        self.lblChonCa.text = ""
                                                                        
                                                                    }
                                                                    if(dayOffStatus == 0){
                                                                        self.view.makeToast("Xin đi trễ về sớm không thành công", duration: 2.0, position: .center)
                                                                    }
                                                                }
                                                            }
                                                        })
                                                        
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                        
                    }
                }
                
                
            }
        }
        
    }
    }
    
    
}

