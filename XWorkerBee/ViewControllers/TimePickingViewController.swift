//
//  TimePickingViewController.swift
//  XWorkerBee
//
//  Created by Chan on 2/8/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import Firebase

class TimePickingViewController: BaseViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var vLineHorizotal: UIView!
    @IBOutlet weak var vTimeIndicator: UIView!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    
    @IBOutlet weak var btnCheckInOut: UIButton!
    @IBOutlet weak var locationStatusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var mSrollView: UIScrollView!
    @IBOutlet weak var vCheckInOutStatusDialog: UIView!
    @IBOutlet weak var vSuccess: UIView!
    @IBOutlet weak var imgCapture: UIImageView!
    @IBOutlet weak var lblCheckInOutResult: UILabel!
    @IBOutlet weak var lblCheckInOutTime: UILabel!
    //@IBOutlet weak var lblCheckInOutLocation: UILabel!
    @IBOutlet weak var btnCloseDialog: UIButton!
    @IBOutlet weak var vUnsuccess: UIView!
    @IBOutlet weak var lblUnsuccessTitle: UILabel!
    @IBOutlet weak var btnUNsuccess: UIButton!
    
    var refreshControl = UIRefreshControl()
    //var btnCheckInOut: UIButton!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D!
    
    var checkInOutStatus: Int!
    //var checkRadius: Bool!
    //var radius: Double!
    //var userLongitude: Double!
    //var userLatitude: Double!
    
    var timer = Timer()
    let dateFormatter = DateFormatter()
    //var timeLabel: UILabel!
    //var locationStatusLabel: UILabel!
    
    var isCameraOpened = false
    
    var hadAddedCheckInOutButton = false
    
    var rightBarBtnUser: UIBarButtonItem!
    
    @IBAction func btnCheckInOutAction(_ sender: Any) {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("no access")
                let alertController = UIAlertController(title: "Thông báo", message: "Vui lòng cho phép ứng dụng truy cập vị trí của bạn", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: NSLocalizedString("Huỷ", comment: ""), style: .cancel, handler: nil)
                let settingsAction = UIAlertAction(title: NSLocalizedString("Cài đặt", comment: ""), style: .default) { (UIAlertAction) in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
                }
                alertController.addAction(cancelAction)
                alertController.addAction(settingsAction)
                self.present(alertController, animated: true, completion: nil)
                
            case .authorizedAlways, .authorizedWhenInUse: do {
                let accountCode = UserDefaults.standard.string(forKey: User.ACCOUNT_CODE)?.lowercased()
                let userName = UserDefaults.standard.string(forKey: User.USER_NAME)?.lowercased()
                if(accountCode == Constant.APPLE_USER_CODE && userName == Constant.APPLE_USER_NAME){
                    saveCheckInOut(fileData: nil, fileName: accountCode! + userName!, isCheckIn: self.checkInOutStatus == Constant.KEY_VERIFY_NEED_CHECK_IN ? true : false)
                }else{
                    self.determineCheckInOut(isVerifyCheckInOrCheckOutButton: false, isCheckInOrCheckOutButtonClick: true, isLocationChange: false)
                }
            }
        }
        }else {
            print("Location services are not enabled")
            let alertController = UIAlertController(title: "Thông báo", message: "GPS thì đang tắt. Vui lòng mở GPS", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: NSLocalizedString("Đóng", comment: ""), style: .default) { (UIAlertAction) in
                //UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            }
            alertController.addAction(settingsAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
//    @objc func showBadge() {
//        Utils.showBadgeNumber(navItem: self.navigationItem, index: 0)
//    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup time indicator
        vLineHorizotal.backgroundColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR).withAlphaComponent(0.3)
        vTimeIndicator.layer.borderWidth = 1
        vTimeIndicator.layer.borderColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR).withAlphaComponent(0.3).cgColor
        vTimeIndicator.layer.cornerRadius = 5
        lblStartTime.numberOfLines = 1
        lblStartTime.minimumScaleFactor = 0.7
        lblStartTime.adjustsFontSizeToFitWidth = true
        lblEndTime.numberOfLines = 1
        lblEndTime.minimumScaleFactor = 0.7
        lblEndTime.adjustsFontSizeToFitWidth = true
        vTimeIndicator.isHidden = true
        lblStartTime.textColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR).withAlphaComponent(0.7)
        lblEndTime.textColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR).withAlphaComponent(0.7)
        
        //add slide menu
        addSlideMenuButton()
        
        //setup title
        let navView = Utils.configTitleNavBar(navBar: (self.navigationController?.navigationBar)!)
        self.navigationItem.titleView = navView
        navView.sizeToFit()
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.barTintColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR)
        
        //setup background
        SharedClass.sharedInstance.backgroundImage(view: self.view)
        
        //setup forcus menu
        //UserDefaults.standard.set(Menu.CHAM_CONG_MENU, forKey: User.MENU_SELECTED)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(TimePickingViewController.showBadge), name: .showBadge, object: nil)

        
        //setup pull to refresh
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.tintColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR)
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        self.mSrollView.refreshControl = refreshControl
        
        //setup timer
        setupTimerLabel()
        dateFormatter.dateFormat = "HH:mm:ss"
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true);
        
        //setup location status
        setupLocationStatusLabel()
        setupAnalytic()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        Utils.showBadgeNumber(navItem: self.navigationItem, index: 0)
        
        //show notification number badge
        //NotificationCenter.default.post(name: .showBadge, object: nil)
        
        //set notification right bar item menu
//        let notiMenu = UIButton(type: .custom)
//        notiMenu.setImage(#imageLiteral(resourceName: "ic_bell"), for: .normal)
//        notiMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        notiMenu.addTarget(self, action: #selector(TimePickingViewController.openNotificationViewByMenu), for: .touchUpInside)
//        let rightBarBtnUser = UIBarButtonItem(customView: notiMenu)
//        self.navigationItem.setRightBarButtonItems([rightBarBtnUser], animated: true)
        
        
        //hide dialog view check in or check out result
        self.vCheckInOutStatusDialog.isHidden = true
        
        //setup check in out button
        setupCheckInOutButton()
        
        //config location services
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        //determine check in or check out
        didBecomeActive()
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
    
    override func viewDidDisappear(_ animated: Bool) {
        Utils.loading(self.view, startAnimate: false)
        locationManager.stopUpdatingLocation()
    }
    private func setupAnalytic() {
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-\(title ?? "")",
            AnalyticsParameterItemName: title ?? "",
            AnalyticsParameterContentType: "cont"
            ])
    }
    
    func openLoginVC(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let lvc = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(lvc, animated: true, completion: nil)
    }
    
    // my selector that was defined above
    @objc func didBecomeActive() {
        if let _ = UserDefaults.standard.string(forKey: User.USER_ID){
            RequestManager.getUserStatus(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, completionHandler: {(status, msg) -> Void in
                if(status){
                    if let userStatus = msg.dictionary{
                        Utils.loading(self.view, startAnimate: false)
                        let expire = userStatus["GiaHan"]?.int
                        let lock = userStatus["Block"]?.int
                        if(lock == Constant.USER_STATUS_BLOCK){
                            self.view.makeToast("Rất tiếc. Tài khoản của bạn đã bị khoá!!!", duration: 2.0, position: .center)
                            Utils.logout()
                            self.openLoginVC()
                        }else{
                            if(expire == Constant.USER_STATUS_EXPIRE){
                                self.view.makeToast("Rất tiếc. Tài khoản của bạn đã hết hạn!!!", duration: 2.0, position: .center)
                                Utils.logout()
                                self.openLoginVC()
                            }else{
                                if(!self.isCameraOpened){
                                    self.determineCheckInOut(isVerifyCheckInOrCheckOutButton: true, isCheckInOrCheckOutButtonClick: false, isLocationChange: false)
                                }else{
                                    self.isCameraOpened = false
                                }
                            }
                        }
                    }
                }
            })
        }else{
            self.openLoginVC()
        }
    }
    
    @IBAction func btnCloseUnsuccessDialogAction(_ sender: Any) {
        self.vCheckInOutStatusDialog.isHidden = true
    }
    @IBAction func btnCloseDialogAction(_ sender: Any) {
        self.vCheckInOutStatusDialog.isHidden = true
    }
    
    func showDialogCheckInOutUnsuccess(isCheckIn: Bool){
             Utils.loading(self.view, startAnimate: false)
        self.vCheckInOutStatusDialog.isHidden = false
        self.vUnsuccess.layer.cornerRadius = 10
        self.vUnsuccess.isHidden = false
        self.vSuccess.isHidden = true
        
        self.btnUNsuccess.backgroundColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR)
        self.btnUNsuccess.setTitleColor(UIColor.black, for: .normal)
        self.btnUNsuccess.layer.cornerRadius = 15
        
        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = UIImage(named:"ic_fail20pt")
        let imageOffsetY:CGFloat = -5.0;
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(attachmentString)
        var textAfterIcon = NSMutableAttributedString()
        if(isCheckIn){
            textAfterIcon = NSMutableAttributedString(string: " Check in không thành công")
        }else{
            textAfterIcon = NSMutableAttributedString(string: " Check out không thành công")
        }
        completeText.append(textAfterIcon)
        self.lblUnsuccessTitle.textAlignment = .center;
        self.lblUnsuccessTitle.attributedText = completeText
        self.lblUnsuccessTitle.textColor = UIColor.red
    }
    
    func showDialogCheckInOutSuccess(isCheckIn: Bool, img: UIImage, address: String){
             Utils.loading(self.view, startAnimate: false)
        self.vCheckInOutStatusDialog.isHidden = false
        self.vSuccess.layer.cornerRadius = 10
        self.vSuccess.isHidden = false
        self.vUnsuccess.isHidden = true
        
        self.btnCloseDialog.backgroundColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR)
        self.btnCloseDialog.setTitleColor(UIColor.white, for: .normal)
        self.btnCloseDialog.layer.cornerRadius = 15
        
        self.imgCapture.isHidden = false
        self.lblCheckInOutTime.isHidden = false
        //self.lblCheckInOutLocation.isHidden = false
        
        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = UIImage(named:"ic_checked20pt")
        let imageOffsetY:CGFloat = -5.0;
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(attachmentString)
        var textAfterIcon = NSMutableAttributedString()
        
        if(isCheckIn){
            textAfterIcon = NSMutableAttributedString(string: " Check in thành công")
            completeText.append(textAfterIcon)
            self.lblCheckInOutResult.attributedText = completeText;
        }else{
            textAfterIcon = NSMutableAttributedString(string: " Check out thành công")
            completeText.append(textAfterIcon)
            self.lblCheckInOutResult.attributedText = completeText;
        }
        self.lblCheckInOutResult.textAlignment = .center;
        self.lblCheckInOutResult.textColor = Utils.convertHexStringToUIColor(hex: Color.GREEN_COLOR)
        
        //show timer
        
        if let time = timeLabel.text{
            let imageAttachment =  NSTextAttachment()
            imageAttachment.image = UIImage(named:"ic_clock20pt")
            let imageOffsetY:CGFloat = -5.0;
            imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
            let attachmentString = NSAttributedString(attachment: imageAttachment)
            let completeText = NSMutableAttributedString(string: "")
            completeText.append(attachmentString)
            let textAfterIcon = NSMutableAttributedString(string: " " + time)
            completeText.append(textAfterIcon)
            self.lblCheckInOutTime.textAlignment = .center;
            self.lblCheckInOutTime.attributedText = completeText;
        }
        self.imgCapture.image = img
    }
    
    @objc func pullToRefresh(_ sender: Any) {
        self.determineCheckInOut(isVerifyCheckInOrCheckOutButton: true, isCheckInOrCheckOutButtonClick: false, isLocationChange: false)
        refreshControl.endRefreshing()
    }
    
    
    //Verify check in or check out
    func determineCheckInOut(isVerifyCheckInOrCheckOutButton: Bool, isCheckInOrCheckOutButtonClick: Bool, isLocationChange: Bool){
        let (hour, minute, dayOfWeek) = Utils.getTime()
        if let _ = UserDefaults.standard.string(forKey: User.USER_ID){
            RequestManager.determine(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, day: dayOfWeek, hours: hour, minutes: minute, completionHandler: {(url, status, msg) -> Void in
                RequestManager.insertLog(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, deviceType: UIDevice.modelName, flatForm: "iOS", logType: Log.LOG_ACTION, logMessage: "DetermineCheckInOut", logDescription: url, completionHandler: nil)
                if(status){
                    if let result = msg.dictionary{
    
                        self.lblStartTime.text = "Giờ bắt đầu ca: " + (result["GioBatDau"]?.string!)!
                        self.lblEndTime.text = "Giờ kết thúc ca: " + (result["GioKetThuc"]?.string!)!
                        
                        
                        if let _ = result["XetBanKinh"]?.int {
              
                            let checkRadius = result["XetBanKinh"]?.int
                            let lat = result["ViDo"]?.double
                            let long = result["KinhDo"]?.double
                            let radius = result["BanKinh"]?.double
                            
                            if(!isLocationChange){
                                if(!isCheckInOrCheckOutButtonClick){
                                    self.checkInOutStatus = result["KetQua"]?.int}
                            }
                            
                            if checkRadius == Constant.KEY_NEED_CHECK_RADIUS && self.currentLocation != nil {
                                let userCoordinate = CLLocation(latitude: lat!, longitude: long!)
                                let deviceCoordinate = CLLocation(latitude: self.currentLocation.latitude, longitude: self.currentLocation.longitude)
                                let distanceInMeters = Double(userCoordinate.distance(from: deviceCoordinate))
                                
                                if(distanceInMeters > radius!){
                                    self.showLocationStatus(locationStatusValid: 2) //invalid
                                    if(isCheckInOrCheckOutButtonClick){
                                        if(self.checkInOutStatus == Constant.KEY_VERIFY_NEED_CHECK_IN){
                                            self.view.makeToast("Địa điểm check in không hợp lệ!", duration: 2.0, position: .center)
                                        }
                                        if(self.checkInOutStatus == Constant.KEY_VERIFY_NEED_CHECK_OUT){
                                            self.view.makeToast("Địa điểm check out không hợp lệ!", duration: 2.0, position: .center)
                                        }
                                    }
                                }else{
                                    self.showLocationStatus(locationStatusValid: 1) //valid
                                    if(isCheckInOrCheckOutButtonClick){
                                        self.determineCheckInOutAgain()
                                    }
                                }
                            }else{
                                if checkRadius != Constant.KEY_NEED_CHECK_RADIUS {
                                    self.showLocationStatus(locationStatusValid: 0) //don't show location status
                                    if(isCheckInOrCheckOutButtonClick){
                                        self.determineCheckInOutAgain()
                                    }
                                }
                            }
                            if(isVerifyCheckInOrCheckOutButton){
                                self.setCheckInOutStatusForButton(checkInOutStatus: self.checkInOutStatus)
                            }
                            
                        }else{
                            self.view.makeToast("Lỗi không lấy được bán kính quy định theo user", duration: 2.0, position: .center)
//                            //account not exist
//                            Utils.logout()
//                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//                            let lvc = storyBoard.instantiateViewController(withIdentifier: Menu.DANG_XUAT_MENU) as! LoginViewController
//                            self.present(lvc, animated: true, completion: nil)
                        }
                    }
                }else{
                    if(msg.string == "timeout"){
                        self.view.makeToast("Lỗi kết nối. Bạn vui lòng thử lại!", duration: 2.0, position: .center)
                    }
                    if(msg.string == "error"){
                        self.view.makeToast("Lỗi không xác định được ca chấm công!", duration: 2.0, position: .center)
                    }
                }
            })
        }
    }
    
    
    func setCheckInOutStatusForButton(checkInOutStatus: Int){
        if(checkInOutStatus == Constant.KEY_VERIFY_NEED_CHECK_IN){
            //btnCheckInOut!.setTitle("CHECK IN", for: .normal)
            btnCheckInOut.setImage(#imageLiteral(resourceName: "bg_checkin"), for: .normal)
            btnCheckInOut.isHidden = false
            btnCheckInOut.tintColor = UIColor.clear
            vTimeIndicator.isHidden = false
        }
        
        if(checkInOutStatus == Constant.KEY_VERIFY_NEED_CHECK_OUT){
            //btnCheckInOut!.setTitle("CHECK OUT", for: .normal)
            btnCheckInOut!.setImage(#imageLiteral(resourceName: "bg_checkout"), for: .normal)
            btnCheckInOut!.isHidden = false
            btnCheckInOut.tintColor = UIColor.clear
            vTimeIndicator.isHidden = false
        }
        
        if(checkInOutStatus == Constant.KEY_VERIFY_NO_NEED_CHECK_IN ||
            checkInOutStatus == Constant.KEY_VERIFY_NO_NEED_CHECK_OUT ||
            checkInOutStatus == Constant.KEY_VERIFY_NOT_YET_SCHEDULE){
            btnCheckInOut!.isHidden = true
            //            if let viewWithTag = self.mSrollView.viewWithTag(100) {
            //                viewWithTag.removeFromSuperview()
            //            }
        }
        
        if(checkInOutStatus == Constant.KEY_VERIFY_NO_NEED_CHECK_IN ||
            checkInOutStatus == Constant.KEY_VERIFY_NO_NEED_CHECK_OUT){
            vTimeIndicator.isHidden = true
        }
        if(checkInOutStatus == Constant.KEY_VERIFY_NOT_YET_SCHEDULE){
            vTimeIndicator.isHidden = false
        }
        
    }
    
    
    func determineCheckInOutAgain(){
        //Verify check in or check out
        let (hour, minute, dayOfWeek) = Utils.getTime()
        if let _ = UserDefaults.standard.string(forKey: User.USER_ID){
            RequestManager.determine(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, day: dayOfWeek, hours: hour, minutes: minute, completionHandler: {(url, status, msg) -> Void in
                RequestManager.insertLog(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, deviceType: UIDevice.modelName, flatForm: "iOS", logType: Log.LOG_ACTION, logMessage: "DetermineCheckInOut", logDescription: url, completionHandler: nil)
                if(status){
                    if let result = msg.dictionary{
                        let checkInOutNewest = result["KetQua"]?.int
                        if(checkInOutNewest == self.checkInOutStatus){
                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let cvc = storyBoard.instantiateViewController(withIdentifier: "idCameraVC") as! CameraViewController
                            cvc.camDelegate = self
                            self.present(cvc, animated: true, completion: nil)
                        }else{
                            if(self.checkInOutStatus == Constant.KEY_VERIFY_NEED_CHECK_IN){
                                self.view.makeToast("Bạn đã checkin rồi", duration: 2.0, position: .center)
                            }
                            
                            if(self.checkInOutStatus == Constant.KEY_VERIFY_NEED_CHECK_OUT){
                                self.view.makeToast("Bạn đã checkout rồi", duration: 2.0, position: .center)
                            }
                            self.checkInOutStatus = checkInOutNewest
                            self.setCheckInOutStatusForButton(checkInOutStatus: self.checkInOutStatus)
                        }
                    }
                }else{
                    if(msg.string == "timeout"){
                        Utils.loading(self.view, startAnimate: false)
                        self.view.makeToast("Lỗi kết nối. Bạn vui lòng thử lại!", duration: 2.0, position: .center)
                    }
                }
            })
        }
    }
    
    
    @objc func btnCheckInOutAction(sender: UIButton!) {
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = manager.location?.coordinate
        //print("\(currentLocation.latitude) - \(currentLocation.latitude)")
        
        let userCode = UserDefaults.standard.string(forKey: User.USER_CODE)?.lowercased()
        let userName = UserDefaults.standard.string(forKey: User.USER_NAME)?.lowercased()
        if(userCode == Constant.APPLE_USER_CODE && userName == Constant.APPLE_USER_NAME){
            self.showLocationStatus(locationStatusValid: 0) //don't show location status
            return;
        }else{
            self.determineCheckInOut(isVerifyCheckInOrCheckOutButton: false, isCheckInOrCheckOutButtonClick: false, isLocationChange: true)
        }
    }
    
    func uploadFileToFTP(fileData: Data, fileName: String, isCheckIn:Bool){
        let ftpUpload = FTPUpload(baseUrl: Constant.FTP_URL,
                                  userName: Constant.FTP_USER,
                                  password: Constant.FTP_PASS,
                                  directoryPath: isCheckIn == true ? Constant.FTP_PATH_CHECK_IN : Constant.FTP_PATH_CHECK_OUT)
        ftpUpload.send(data: fileData, with: fileName, success: {(uploadStatus) -> Void in
            if(uploadStatus){
                self.saveCheckInOut(fileData: fileData, fileName: fileName, isCheckIn: isCheckIn)
            }else{
                self.view.makeToast("Không thể tải hình lên server", duration: 2.0, position: .center)
            }
        })
    }
    
    func saveCheckInOut(fileData: Data!, fileName: String, isCheckIn: Bool){
        
        /* USE Multipart/form-data */
        Utils.loading(self.view, startAnimate: true)
        if(isCheckIn){
            RequestManager.checkInV2(imageData: fileData, fileName: fileName, userId: UserDefaults.standard.string(forKey: User.USER_ID)!, log: self.currentLocation.longitude, lat: self.currentLocation.latitude, completionHandler: {(url, status, msg) -> Void in
                RequestManager.insertLog(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, deviceType: UIDevice.modelName, flatForm: "iOS", logType: Log.LOG_ACTION, logMessage: "CheckIn", logDescription: url, completionHandler: nil)
       
                if(status){
                    let checkInStatusResult = msg["KetQua"].int
                    if(checkInStatusResult == Constant.KEY_CHECK_IN_RESULT_SUCCESS){
                        self.determineCheckInOut(isVerifyCheckInOrCheckOutButton: true, isCheckInOrCheckOutButtonClick: false, isLocationChange: false)
                        if(fileData != nil){
                            self.showDialogCheckInOutSuccess(isCheckIn: true, img: UIImage(data: fileData)!, address: "")
                        }
                    }else{
                        self.showDialogCheckInOutUnsuccess(isCheckIn: true)
                    }
                }else{
                    if(msg.string == "timeout"){
                        Utils.loading(self.view, startAnimate: false)
                        self.view.makeToast("Lỗi kết nối. Bạn vui lòng thử lại!", duration: 2.0, position: .center)
                    }else{
                        self.showDialogCheckInOutUnsuccess(isCheckIn: true)
                    }
                }
            })
        }
        else{
            RequestManager.checkOutV2(imageData: fileData, fileName: fileName, userId: UserDefaults.standard.string(forKey: User.USER_ID)!, log: self.currentLocation.longitude, lat: self.currentLocation.latitude, completionHandler: {(url, status, msg) -> Void in
                RequestManager.insertLog(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, deviceType: UIDevice.modelName, flatForm: "iOS", logType: Log.LOG_ACTION, logMessage: "CheckOut", logDescription: url, completionHandler: nil)
                if(status){
                    let checkOutStatusResult = msg["KetQua"].int
                    if(checkOutStatusResult == Constant.KEY_CHECK_OUT_RESULT_SUCCESS){
                        self.determineCheckInOut(isVerifyCheckInOrCheckOutButton: true, isCheckInOrCheckOutButtonClick: false, isLocationChange: false)
                        if fileData != nil{
                            self.showDialogCheckInOutSuccess(isCheckIn: false, img: UIImage(data: fileData)!, address: "")
                        }
                    }else{
                        self.showDialogCheckInOutUnsuccess(isCheckIn: false)
                    }
                }else{
                    if(msg.string == "timeout"){
                        Utils.loading(self.view, startAnimate: false)
                        self.view.makeToast("Lỗi kết nối. Bạn vui lòng thử lại!", duration: 2.0, position: .center)
                    }else{
                        self.showDialogCheckInOutUnsuccess(isCheckIn: false)
                    }
                }
            })
        }
        
        
        /* USE FTP upload */
        //        Utils.loading(self.view, startAnimate: true)
        //        if(isCheckIn){
        //            RequestManager.checkIn(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, log: self.location.longitude, lat: self.location.latitude, fileName: fileName, completionHandler: {(url, status, msg) -> Void in
        //                RequestManager.insertLog(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, deviceType: UIDevice.modelName, flatForm: "iOS", logType: Log.LOG_ACTION, logMessage: "CheckIn", logDescription: url, completionHandler: nil)
        //                Utils.loading(self.view, startAnimate: false)
        //                if(status){
        //                    let checkInStatusResult = msg["KetQua"].int
        //                    if(checkInStatusResult == Constant.KEY_CHECK_IN_RESULT_SUCCESS){
        //                        self.determineCheckInOut()
        //                        if(fileData != nil){
        //                            self.showDialogCheckInOutSuccess(isCheckIn: true, img: UIImage(data: fileData)!, address: "")
        //                        }
        //                    }else{
        //                        self.showDialogCheckInOutUnsuccess(isCheckIn: true)
        //                    }
        //                }else{
        //                     self.showDialogCheckInOutUnsuccess(isCheckIn: true)
        //                }
        //            })
        //        }else{
        //            RequestManager.checkOut(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, log: self.location.longitude, lat: self.location.latitude, fileName: fileName, completionHandler: {(url, status, msg) -> Void in
        //                RequestManager.insertLog(userId: UserDefaults.standard.string(forKey: User.USER_ID)!, deviceType: UIDevice.modelName, flatForm: "iOS", logType: Log.LOG_ACTION, logMessage: "CheckOut", logDescription: url, completionHandler: nil)
        //                Utils.loading(self.view, startAnimate: false)
        //                if(status){
        //                    let checkOutStatusResult = msg["KetQua"].int
        //                    if(checkOutStatusResult == Constant.KEY_CHECK_OUT_RESULT_SUCCESS){
        //                        self.determineCheckInOut()
        //                        if fileData != nil{
        //                            self.showDialogCheckInOutSuccess(isCheckIn: false, img: UIImage(data: fileData)!, address: "")
        //                        }
        //                    }else{
        //                         self.showDialogCheckInOutUnsuccess(isCheckIn: false)
        //                    }
        //                }else{
        //                     self.showDialogCheckInOutUnsuccess(isCheckIn: false)
        //                }
        //            })
        //        }
    }
    
    func setupLocationStatusLabel(){
        //locationStatusLabel = UILabel()
        locationStatusLabel.font = UIFont.systemFont(ofSize: 17)
        locationStatusLabel.textAlignment = .center
        //self.mSrollView.addSubview(locationStatusLabel)
        
        //locationStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        //locationStatusLabel.centerXAnchor.constraint(equalTo: self.mSrollView.centerXAnchor).isActive = true
        //locationStatusLabel.topAnchor.constraint(equalTo: self.mSrollView.topAnchor, constant: 50).isActive = true
    }
    
    func showLocationStatus(locationStatusValid: Int){
        if(locationStatusValid == 0){
            self.locationStatusLabel.text = ""
            self.locationStatusLabel.isHidden = true
        }
        if(locationStatusValid == 1){
            //Create Attachment
            let imageAttachment =  NSTextAttachment()
            imageAttachment.image = UIImage(named:"ic_location20pt_green")
            //Set bound to reposition
            let imageOffsetY:CGFloat = -5.0;
            imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
            //Create string with attachment
            let attachmentString = NSAttributedString(attachment: imageAttachment)
            //Initialize mutable string
            let completeText = NSMutableAttributedString(string: "")
            //Add image to mutable string
            completeText.append(attachmentString)
            //Add your text to mutable string
            let  textAfterIcon = NSMutableAttributedString(string: " Địa điểm hợp lệ!")
            completeText.append(textAfterIcon)
            self.locationStatusLabel.textAlignment = .center;
            self.locationStatusLabel.attributedText = completeText;
            self.locationStatusLabel.isHidden = false
            self.locationStatusLabel.textColor = Utils.convertHexStringToUIColor(hex: Color.GREEN_COLOR)
        }
        if(locationStatusValid == 2){
            //Create Attachment
            let imageAttachment =  NSTextAttachment()
            imageAttachment.image = UIImage(named:"ic_location20pt_red")
            //Set bound to reposition
            let imageOffsetY:CGFloat = -5.0;
            imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
            //Create string with attachment
            let attachmentString = NSAttributedString(attachment: imageAttachment)
            //Initialize mutable string
            let completeText = NSMutableAttributedString(string: "")
            //Add image to mutable string
            completeText.append(attachmentString)
            //Add your text to mutable string
            let  textAfterIcon = NSMutableAttributedString(string: " Địa điểm không hợp lệ!")
            completeText.append(textAfterIcon)
            self.locationStatusLabel.textAlignment = .center;
            self.locationStatusLabel.attributedText = completeText;
            self.locationStatusLabel.isHidden = false
            self.locationStatusLabel.textColor = UIColor.red
        }
    }
    
    func setupTitle(){
        if let _ = UserDefaults.standard.string(forKey: User.USER_ID){
            if let _ = UserDefaults.standard.string(forKey: User.COMPANY_NAME){
                setupNavigationBar(title: UserDefaults.standard.string(forKey: User.COMPANY_NAME)!)
            }
        }
    }
    
    func setupTimerLabel(){
        //timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.center.y = self.mSrollView.center.y
        timeLabel.textAlignment = .center
        timeLabel.textColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR)
        
        switch UIDevice.current.userInterfaceIdiom{
        case .phone:
              timeLabel.font = UIFont.systemFont(ofSize: 40)
        case .pad:
              timeLabel.font = UIFont.systemFont(ofSize: 55)
        case .unspecified:
            break
        case .tv: break
        case .carPlay: break
        }
      
        //self.mSrollView.addSubview(timeLabel)
        //timeLabel.centerXAnchor.constraint(equalTo: self.mSrollView.centerXAnchor).isActive = true
        //timeLabel.centerYAnchor.constraint(equalTo: self.mSrollView.centerYAnchor, constant: -100).isActive = true
    }
    
    func setupCheckInOutButton(){
        if let _ = UserDefaults.standard.string(forKey: User.USER_ID){
            if !self.hadAddedCheckInOutButton{
                //let screenSize = UIScreen.main.bounds
                //let screenWidth = screenSize.width
                //let buttonSize = screenWidth / 2.5
                
                //btnCheckInOut = UIButton()
                //btnCheckInOut!.layer.borderWidth = Constant.BORDER_LINE_HEIGHT
                //btnCheckInOut!.layer.borderColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR).cgColor
                //btnCheckInOut!.setTitleColor(UIColor.black, for: .normal)
                //btnCheckInOut!.backgroundColor = Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR)
                //                btnCheckInOut!.tag = 100
                //                btnCheckInOut!.addTarget(self, action: #selector(btnCheckInOutAction), for: .touchUpInside)
                //                btnCheckInOut!.isHidden = true
                //                self.mSrollView.addSubview(btnCheckInOut!)
                //                btnCheckInOut!.translatesAutoresizingMaskIntoConstraints = false
                //                btnCheckInOut!.centerXAnchor.constraint(equalTo: self.mSrollView.centerXAnchor).isActive = true
                //                btnCheckInOut!.centerYAnchor.constraint(equalTo: self.mSrollView.centerYAnchor).isActive = true
                //                btnCheckInOut!.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
                //                btnCheckInOut!.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
                //                btnCheckInOut!.layer.cornerRadius = buttonSize / 2
                self.btnCheckInOut.isHidden = true
                self.hadAddedCheckInOutButton = true
            }
        }
    }
    
    @objc func updateTimeLabel() {
        let date = Date()
        timeLabel.text = dateFormatter.string(from: date)
    }
    
}

extension TimePickingViewController: CameraViewControllerDelegate{
    func receiveData(data: Data?) {
        Utils.loading(self.view, startAnimate: true)
        self.isCameraOpened = true
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss.SSSSSS"
        let fileName = UserDefaults.standard.string(forKey: User.ACCOUNT_CODE)!.lowercased()
            + "-"
            + UserDefaults.standard.string(forKey: User.USER_ID)!
            + "-"
            + formatter.string(from: date)
            + ".jpg"
        let image = UIImage(data: data!)
        //let dataRotate = (image?.imageRotated(on: 90))!.jpegData(compressionQuality: 1)
        let dataRotate = image?.fixOrientation().jpegData(compressionQuality: 0.15)
        self.saveCheckInOut(fileData: dataRotate!, fileName: fileName, isCheckIn: self.checkInOutStatus == Constant.KEY_VERIFY_NEED_CHECK_IN ? true: false)
        //uploadFileToFTP(fileData: dataRotate!, fileName: fileName, isCheckIn: self.checkInOutStatus == Constant.KEY_VERIFY_NEED_CHECK_IN ? true : false)
    }
}

extension UIImage {
    
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
    
    func imageRotated(on degrees: CGFloat) -> UIImage {
        // Following code can only rotate images on 90, 180, 270.. degrees.
        let degrees = round(degrees / 90) * 90
        let sameOrientationType = Int(degrees) % 180 == 0
        let radians = CGFloat.pi * degrees / CGFloat(180)
        let newSize = sameOrientationType ? size : CGSize(width: size.width, height: size.height)
        
        UIGraphicsBeginImageContext(newSize)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let ctx = UIGraphicsGetCurrentContext(), let cgImage = cgImage else {
            return self
        }
        
        ctx.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        ctx.rotate(by: radians)
        ctx.scaleBy(x: 1, y: -1)
        let origin = CGPoint(x: -(size.width / 2), y: -(size.height / 2))
        let rect = CGRect(origin: origin, size: size)
        ctx.draw(cgImage, in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image ?? self
    }
    
}
