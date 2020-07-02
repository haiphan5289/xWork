//
//  ReportViewController.swift
//  XWorkerBee
//
//  Created by Chan on 2/18/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit
import DatePickerDialog
import SwiftyJSON
import MonthYearPicker

class ReportViewController: BaseViewController {
    @IBOutlet weak var vDatePicker: UIView!
    @IBOutlet weak var btnCloseDatePicker: UIButton!
    @IBOutlet weak var btnSelectDatePicker: UIButton!
    
    @IBOutlet weak var vSelectDate: UIView!
    @IBOutlet weak var imgSelectDate: UIImageView!
    @IBOutlet weak var lbSelectDate: UILabel!
    
    @IBOutlet weak var vReportData: UIView!
    @IBOutlet weak var tb1: UITableView!
    @IBOutlet weak var tb2: UITableView!
    private var refreshControlTB1: UIRefreshControl = UIRefreshControl()
    private var refreshControlTB2: UIRefreshControl = UIRefreshControl()

    
    var data1 = [[String]]()
    var data2 = [JSON]()
    var html = String()
    var dateSelect = Date()
    
    var formatter = DateFormatter()
    var monthFormatter = DateFormatter()
    var yearFormatter = DateFormatter()
    private var countView: Int = 0
    private var arr: [Dictionary<String,Any>] = [Dictionary<String,Any>]()
    var alert: UIAlertController!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAlert()
        present(alert, animated: true, completion: nil)
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
        //NotificationCenter.default.addObserver(self, selector: #selector(ReportViewController.showBadgeAtReportVC), name: .showBadgeAtReportVC, object: nil)
        
        vSelectDate.layer.cornerRadius = Constant.BORDER_RADIUS
        vReportData.layer.cornerRadius = 10
        
        self.monthFormatter.dateFormat = "MM"
        self.yearFormatter.dateFormat = "yyyy"
        self.formatter.dateFormat = "MM/yyyy"
        
        self.tb1.delegate = self
        self.tb1.dataSource = self
        self.tb1.tableFooterView = UIView()
        self.tb1.isScrollEnabled = true
        self.tb1.refreshControl = refreshControlTB1
        self.refreshControlTB1.addTarget(self, action: #selector(handleRefreshTableView1), for: .valueChanged)
        
        self.tb2.delegate = self
        self.tb2.dataSource = self
        self.tb2.tableFooterView = UIView()
        self.tb2.refreshControl = refreshControlTB2

       self.refreshControlTB2.addTarget(self, action: #selector(handleRefreshTableView2), for: .valueChanged)
        
        self.vDatePicker.layer.cornerRadius = 5
        self.vDatePicker.isHidden = true
        
        let picker = MonthYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: (self.vDatePicker.bounds.height - 180) / 2), size: CGSize(width: self.vDatePicker.bounds.width, height: 180)))
        picker.locale = Locale(identifier: "vi_VN")
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        self.vDatePicker.addSubview(picker)
        checkViewedNotification()
//        self.detecNextSchedule()
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenAppFromBG),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        if let _ = UserDefaults.standard.string(forKey: User.COMPANY_NAME){
            //setupNavigationBar(title: UserDefaults.standard.string(forKey: User.COMPANY_NAME)!)
            
            //self.vReport.dropShadow(color: .lightGray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
            
            let date = Date()
            //lbSelectDate.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            lbSelectDate.text = formatter.string(from: date)
            let tap = UITapGestureRecognizer(target: self, action: #selector(ReportViewController.selectDateClick))
            lbSelectDate.isUserInteractionEnabled = true
            lbSelectDate.addGestureRecognizer(tap)
            
            self.getReport(month: monthFormatter.string(from: date), year: yearFormatter.string(from: date))
            self.getReportDetail(month: monthFormatter.string(from: date), year: yearFormatter.string(from: date))
        }
    }
    
    @objc func handleRefreshTableView1(){
        self.refreshAPI()
    }
    @objc func handleRefreshTableView2(){
        self.refreshAPI()
    }
    
    @objc func handleOpenAppFromBG(){
        checkViewedNotification()
//        self.detecNextSchedule()
    }
    
    @objc func dateChanged(_ picker: MonthYearPickerView) {
        print("date changed: \(picker.date)")
        self.dateSelect = picker.date
    }
    
    @IBAction func btnSelectDatePickerAction(_ sender: Any) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/yyyy"
            self.lbSelectDate.text = formatter.string(from: self.dateSelect)
            self.vDatePicker.isHidden = true
        
        self.getReport(month: self.monthFormatter.string(from: dateSelect), year: self.yearFormatter.string(from: dateSelect))
        self.getReportDetail(month: self.monthFormatter.string(from: dateSelect), year: self.yearFormatter.string(from: dateSelect))
        
    }
    @IBAction func btnCloseDatePickerAction(_ sender: Any) {
        self.vDatePicker.isHidden = true
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
//    @objc func showBadgeAtReportVC() {
//        Utils.showBadgeNumber(navItem: self.navigationItem, index: 0)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        Utils.showBadgeNumber(navItem: self.navigationItem, index: 0)
        
        
//        //show notification number badge
//        NotificationCenter.default.post(name: .showBadgeAtNotificationVC, object: nil)
//
//        //set notification right bar item menu
//        let notiMenu = UIButton(type: .custom)
//        notiMenu.setImage(#imageLiteral(resourceName: "ic_bell"), for: .normal)
//        notiMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        notiMenu.addTarget(self, action: #selector(ReportViewController.openNotificationViewByMenu), for: .touchUpInside)
//        let rightBarBtnUser = UIBarButtonItem(customView: notiMenu)
//        self.navigationItem.setRightBarButtonItems([rightBarBtnUser], animated: true)
        

//        if let _ = UserDefaults.standard.string(forKey: User.COMPANY_NAME){
//            //setupNavigationBar(title: UserDefaults.standard.string(forKey: User.COMPANY_NAME)!)
//
//            //self.vReport.dropShadow(color: .lightGray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
//
//            let date = Date()
//            //lbSelectDate.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
//            lbSelectDate.text = formatter.string(from: date)
//            let tap = UITapGestureRecognizer(target: self, action: #selector(ReportViewController.selectDateClick))
//            lbSelectDate.isUserInteractionEnabled = true
//            lbSelectDate.addGestureRecognizer(tap)
//
//            self.getReport(month: monthFormatter.string(from: date), year: yearFormatter.string(from: date))
//            self.getReportDetail(month: monthFormatter.string(from: date), year: yearFormatter.string(from: date))
//        }
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
    private func setupAlert(){
        alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        let activies: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activies.color = #colorLiteral(red: 0.9556708932, green: 0.4114195704, blue: 0.1716270149, alpha: 1)
        activies.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        var height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50)
        alert.view.addConstraint(height)
        var width:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50)
        alert.view.addConstraint(width)
        alert.view.addSubview(activies)
        activies.startAnimating()
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
    
    func getReportDetail(month: String, year: String){
        Utils.loading(self.view, startAnimate: true)
        RequestManager.reportDetail(userId: UserDefaults.standard.string(forKey: User.USER_ID)! ?? "", month: month, year: year, completionHandler: {(status, msg) -> Void in
            if(status){
                if let result = msg.array{
                    self.data2.removeAll()
                    for item in result{
                        self.data2.append(item)
                    }
                    self.tb2.reloadData()
                    Utils.loading(self.view, startAnimate: false)
                    self.refreshControlTB2.endRefreshing()
                    
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.alert.dismiss(animated: true, completion: nil)
                    
                }
                
            } else {
                self.alert.dismiss(animated: true, completion: nil)
                let alert: UIAlertController = UIAlertController(title: "Thông báo", message: "Vui lòng thử lại sau", preferredStyle: .alert)
                let btCancel: UIAlertAction = UIAlertAction(title: "Huỷ", style: .cancel) { _ in
                    self.refreshControlTB2.endRefreshing()
                    Utils.loading(self.view, startAnimate: false)
                }
                alert.addAction(btCancel)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func getReport(month: String, year: String){
        Utils.loading(self.view, startAnimate: true)
        RequestManager.report(userId: UserDefaults.standard.string(forKey: User.USER_ID)! ?? "", month: month, year: year, completionHandler: {(status, msg) -> Void in
            if(status){
                if let result = msg.dictionary{
                    
                    self.data1.removeAll()
                    
                    let fmt = "%0.2f"
                    let SoNgayNghiPhepNam  = result["SoNgayNghiPhepNam"]?.double
                    let SoNgayNghiPhepThuong = result["SoNgayNghiPhepThuong"]?.double
                    let SoNgayNghiKhongPhep = result["SoNgayNghiKhongPhep"]?.double
                    let SoLanDiTre: Int = (result["SoLanDiTre"]?.int)!
                    let SoLanVeSom: Int = (result["SoLanVeSom"]?.int)!
                    let TongGioLam = String(format: fmt, (result["TongGioLam"]?.double)!)
                    let TongSoCong = String(format: fmt, (result["TongSoCong"]?.double)!)
                    
                    
                    //                let header = ["Tổng giờ phân công", "Số giờ trể", "Số giờ về sớm", "Số giờ nghỉ có phép", "Số giờ nghỉ không phép", "Tổng giờ làm thực tế"]
                    //                //self.data.append(header)
                    self.data1.append(["Số ca đi trễ:", String(SoLanDiTre)])
                    self.data1.append(["Số ca về sớm:", String(SoLanVeSom)])
                    self.data1.append(["Số ca nghỉ:",  String(format: fmt, SoNgayNghiPhepNam! + SoNgayNghiPhepThuong! + SoNgayNghiKhongPhep!)])
                    self.data1.append(["Tổng giờ làm thực tế:", TongGioLam])
                    self.data1.append(["Tổng số công:", TongSoCong])
                    
                    self.tb1.reloadData()
//                    Utils.loading(self.view, startAnimate: false)
                    self.refreshControlTB1.endRefreshing()
                    //
                    //                let tableStyle = ".tableClass {width: 100%; font-family: Helvetica; font-size: 13px; border-radius: 2px; border-collapse:collapse; border-style: hidden; box-shadow: 0 0 0 1px #c0c0c0}" +
                    //                    ".headingClass td {width: 15%; background-color: white; text-align:center}" +
                    //                    ".cellClass {font-family: Helvetica; height:40px;}" +
                    //                    " th, td {border: 1px solid #c0c0c0; padding: 5px; text-align:center;}"
                    //
                    //                self.html = Utils.generateTableWithArray(array: self.data, andTableStyle: tableStyle, forTableClassName: "tableClass", andRowClassNames: ["headingClass", nil], andCellClassNames: [nil, ["cellClass", nil, "cellClass", nil]])
                    //                self.wvReport.loadHTMLString(self.html, baseURL: nil)
                } else {
                    let alert: UIAlertController = UIAlertController(title: "Thông báo", message: "Vui lòng thử lại sau", preferredStyle: .alert)
                    let btCancel: UIAlertAction = UIAlertAction(title: "Huỷ", style: .cancel) { _ in
                        self.refreshControlTB1.endRefreshing()
                        Utils.loading(self.view, startAnimate: false)
                    }
                    alert.addAction(btCancel)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
//    func webViewDidFinishLoad(_ webView: UIWebView) {
//        Utils.loading(self.view, startAnimate: false)
//    }
    
    @objc
    func selectDateClick(sender:UITapGestureRecognizer) {
        
        self.vDatePicker.isHidden = false
        
        
//        let date = Date()
//        let datePicker =  DatePickerDialog(locale: Locale(identifier: "vi_VN"))
//        datePicker.show("Chọn  ", doneButtonTitle: "Chọn", cancelButtonTitle: "Đóng", defaultDate: date, minimumDate: nil, maximumDate: nil, datePickerMode: .date, callback: { (date) -> Void in
//            if let dt = date {
//                let formatter = DateFormatter()
//                formatter.dateFormat = "MM/yyyy"
//                self.lbSelectDate.text = formatter.string(from: dt)
//
//                self.getReport(month: self.monthFormatter.string(from: dt), year: self.yearFormatter.string(from: dt))
//                self.getReportDetail(month: self.monthFormatter.string(from: dt), year: self.yearFormatter.string(from: dt))
//            }
//        })
        
    }
}

extension ReportViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == tb1){
            return 40
        }else{
            return 103
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == tb1){
            return data1.count
        }else{
            return data2.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == tb1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "tbCell1", for: indexPath)
                as! ReportTableViewCell1
            let item = data1[indexPath.row]
            cell.lblTitle.text = item[0]
            cell.lblValue.text = item[1]
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "tbCell2", for: indexPath)
                as! ReportTableViewCell2
            let item = data2[indexPath.row]
            cell.lblDate.text = "Ngày: " + item["Ngay"].string!
            cell.lblTimeCheckIn.text = "Giờ vào: " + item["GioVao"].string!
            cell.lblTimeCheckOut.text = "Giờ ra: " + item["GioRa"].string!
            cell.lblGioLam.text = "Giờ làm thực tế: " + String(item["GioLam"].double!)
            cell.lblSoCong.text = "Số công: " + String(item["SoCong"].double!)
            cell.selectionStyle = .none
            return cell
        }
    }
    
}

class ReportTableViewCell1: UITableViewCell{
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    
}

class ReportTableViewCell2: UITableViewCell{
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTimeCheckIn: UILabel!
    @IBOutlet weak var lblTimeCheckOut: UILabel!
    @IBOutlet weak var lblGioLam: UILabel!
    @IBOutlet weak var lblSoCong: UILabel!
    
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var vNgay: UIView!
    @IBOutlet weak var VvGioVao: UIView!
    @IBOutlet weak var vGioRa: UIView!
    @IBOutlet weak var vGioLam: UIView!
    @IBOutlet weak var vSoCong: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let borderWidth = CGFloat(0.3)
        
        let borderColor = UITableView().separatorColor?.cgColor
        
        vContent.layer.borderWidth = borderWidth
        vContent.layer.borderColor = borderColor
        
        VvGioVao.layer.borderWidth = borderWidth
        VvGioVao.layer.borderColor = borderColor
        
        vGioRa.layer.borderWidth = borderWidth
        vGioRa.layer.borderColor = borderColor
        
        vGioLam.layer.borderWidth = borderWidth
        vGioLam.layer.borderColor = borderColor
        
        vSoCong.layer.borderWidth = borderWidth
        vSoCong.layer.borderColor = borderColor
        
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}

extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension ReportViewController {
    private func refreshAPI(){
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        if let year = components.year, let month = components.month {
            self.getReport(month: String(month), year: String(year))
            self.getReportDetail(month: String(month), year: String(year))
            self.lbSelectDate.text = "\(String(month) + "/" + "\(String(year))")"
        }
    }
}

