//
//  Utilss.swift
//  XWorkerBee
//
//  Created by Chan on 2/8/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class Utils : NSObject {
    
//    var menu = MenuViewController()
//    
//    class func addNotificationRightBarItem(navItem: UINavigationItem){
//        //add notification menu
//        let notiMenu = UIButton(type: .custom)
//        notiMenu.setImage(#imageLiteral(resourceName: "ic_bell"), for: .normal)
//        notiMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        notiMenu.addTarget(self, action: #selector(.menu.openNotificationViewByMenu), for: .touchUpInside)
//        let rightBarBtnUser = UIBarButtonItem(customView: notiMenu)
//        navItem.setRightBarButtonItems([rightBarBtnUser], animated: true)
//    }
    
    
    
    class func showBadgeNumber(navItem: UINavigationItem, index: Int){
        let rightBarBtnNotify = navItem.rightBarButtonItems?[index]
        let notifyNumUnread = DataManager().getNotifyListNotYetView()
        
//        if(UserDefaults.standard.bool(forKey: User.SHOW_NOTIFICATION_BADGE_FLAG)){
//            notifyNumUnread = 1
//        }
        
        if(notifyNumUnread > 0){
            //            if(notifyNumUnread == 1){
            //                rightBarBtnNotify?.addBadge(number: notifyNumUnread)
            //            }else{
            rightBarBtnNotify?.removeBadge()
            rightBarBtnNotify?.addBadge(number: notifyNumUnread)
            //                rightBarBtnNotify?.updateBadge(number: notifyNumUnread)
            //            }
        }else{
            rightBarBtnNotify?.removeBadge()
        }
    }
    
    class func roundedPolygonPath(rect: CGRect, lineWidth: CGFloat, sides: NSInteger, cornerRadius: CGFloat, rotationOffset: CGFloat = 0)
        -> UIBezierPath {
            let path = UIBezierPath()
            let theta: CGFloat = CGFloat(2.0 * .pi) / CGFloat(sides) // How much to turn at every corner
            let offset: CGFloat = cornerRadius * tan(theta / 2.0)     // Offset from which to start rounding corners
            let width = min(rect.size.width, rect.size.height)        // Width of the square
            
            let center = CGPoint(x: rect.origin.x + width / 2.0, y: rect.origin.y + width / 2.0)
            
            // Radius of the circle that encircles the polygon
            // Notice that the radius is adjusted for the corners, that way the largest outer
            // dimension of the resulting shape is always exactly the width - linewidth
            let radius = (width - lineWidth + cornerRadius - (cos(theta) * cornerRadius)) / 2.0
            
            // Start drawing at a point, which by default is at the right hand edge
            // but can be offset
            var angle = CGFloat(rotationOffset)
            
            let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
            path.move(to: CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta)))
            
            for _ in 0 ..< sides {
                angle += theta
                
                let corner = CGPoint(x: center.x + (radius - cornerRadius) * cos(angle), y: center.y + (radius - cornerRadius) * sin(angle))
                let tip = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
                let start = CGPoint(x: corner.x + cornerRadius * cos(angle - theta), y: corner.y + cornerRadius * sin(angle - theta))
                let end = CGPoint(x: corner.x + cornerRadius * cos(angle + theta), y: corner.y + cornerRadius * sin(angle + theta))
                
                path.addLine(to: start)
                path.addQuadCurve(to: end, controlPoint: tip)
            }
            
            path.close()
            
            // Move the path to the correct origins
            let bounds = path.bounds
            //let transform = CGAffineTransform(translationX: -bounds.origin.x + rect.origin.x + lineWidth / 2.0, y: -bounds.origin.y + rect.origin.y + lineWidth / 2.0)
            //let transform = CGAffineTransform(translationX: -bounds.origin.x + rect.origin.x + lineWidth, y: -bounds.origin.y + rect.origin.y + lineWidth / 2)
            let transform = CGAffineTransform(translationX: 0,
                                              y: 0)
            path.apply(transform)
            
            return path
    }
    
    class func setupHexagonImageView(imageView: UIImageView) {
        let lineWidth: CGFloat = 2
        let path = Utils.roundedPolygonPath(rect: imageView.bounds,
                                            lineWidth: lineWidth,
                                            sides: 6,
                                            cornerRadius: 2,
                                            rotationOffset: CGFloat(.pi / 2.0))
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.lineWidth = lineWidth
        mask.strokeColor = UIColor.clear.cgColor
        mask.fillColor = UIColor.white.cgColor
        imageView.layer.mask = mask
        
        let border = CAShapeLayer()
        border.path = path.cgPath
        border.lineWidth = lineWidth
        border.strokeColor = convertHexStringToUIColor(hex: Color.MAIN_COLOR).cgColor
        border.fillColor = UIColor.clear.cgColor
        imageView.layer.addSublayer(border)
    }
    
//    func getAddressFromLocation(isCheckIn: Bool, img: UIImage, location: CLLocationCoordinate2D, currentLocation: CLLocationCoordinate2D){
//        let geoCoder = CLGeocoder()
//        let location = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
//        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
//            guard let addressDict = placemarks?[0].addressDictionary else {
//                return
//            }
//            if let formattedAddress = addressDict["FormattedAddressLines"] as? [String] {
//                let address = " " + formattedAddress.joined(separator: ", ")
//            }
//        })
//    }
    
    class func configTitleNavBar(navBar: UINavigationBar) -> UIView{
                
        // Create a navView to add to the navigation bar
        let navView = UIView()
        
        // Create the image view
        let barHeight = navBar.frame.size.height
        let barWidth = navBar.frame.size.width
        let logoHeight = barHeight * 4 / 6
        let logoWidth = (logoHeight * 365) / 62
        let y = 0 - logoHeight / 2
        let x = 0 - (logoWidth / 2)
        
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "ic_header_new")
        image.center = navView.center
        // To maintain the image's aspect ratio:
        //let imageAspect = image.image!.size.width/image.image!.size.height
        //let imageSize = title.frame.size.height + slogan.frame.size.height
        // Setting the image frame so that it's immediately before the text:
        image.frame = CGRect(x: CGFloat(x), y: y, width: logoWidth, height: logoHeight)
        image.contentMode = UIView.ContentMode.scaleAspectFit
        
        //slogan.frame = CGRect(x:title.frame.origin.x, y: (title.frame.origin.y + title.frame.height) - 7, width: title.frame.width, height: slogan.frame.size.height)
        
        // Add both the label and image view to the navView
        navView.addSubview(image)
        
        return navView
    }
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in6()
        zeroAddress.sin6_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin6_family = sa_family_t(AF_INET6)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    enum LINE_POSITION {
        case LINE_POSITION_TOP
        case LINE_POSITION_BOTTOM
    }
    
    class func addLineToView(view : UIView, position : LINE_POSITION, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        view.addSubview(lineView)
        
        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
        
        switch position {
        case .LINE_POSITION_TOP:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .LINE_POSITION_BOTTOM:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        default:
            break
        }
    }
    
    class func convertHexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    @discardableResult
    static func loading(_ viewContainer: UIView, startAnimate:Bool? = true) -> UIActivityIndicatorView {
        let mainContainer: UIView = UIView(frame: viewContainer.frame)
        mainContainer.center = viewContainer.center
        mainContainer.backgroundColor = convertHexStringToUIColor(hex: "#FFFFFF")
        mainContainer.alpha = 0.5
        mainContainer.tag = 789456123
        mainContainer.isUserInteractionEnabled = false
        
        let viewBackgroundLoading: UIView = UIView(frame: CGRect(x:0,y: 0,width: 80,height: 80))
        viewBackgroundLoading.center = viewContainer.center
        viewBackgroundLoading.backgroundColor = convertHexStringToUIColor(hex: "#444444")
        viewBackgroundLoading.alpha = 1
        viewBackgroundLoading.clipsToBounds = true
        viewBackgroundLoading.layer.cornerRadius = 15
        
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x:0.0,y: 0.0,width: 40.0, height: 40.0)
        activityIndicatorView.style =
            UIActivityIndicatorView.Style.whiteLarge
        activityIndicatorView.color = convertHexStringToUIColor(hex: Color.MAIN_COLOR)
        activityIndicatorView.center = CGPoint(x: viewBackgroundLoading.frame.size.width / 2, y: viewBackgroundLoading.frame.size.height / 2)
        if startAnimate!{
            viewBackgroundLoading.addSubview(activityIndicatorView)
            mainContainer.addSubview(viewBackgroundLoading)
            viewContainer.addSubview(mainContainer)
            activityIndicatorView.startAnimating()
        }else{
            for subview in viewContainer.subviews{
                if subview.tag == 789456123{
                    subview.removeFromSuperview()
                }
            }
        }
        return activityIndicatorView
    }
    
    class func generateTableWithArray(array: [[String]], andTableStyle style: String?, forTableClassName tableClassName: String?, andRowClassNames rowClassNames: [String?]?, andCellClassNames cellClassNames: [[String?]?]?) -> String {
        var htmlString = ""
        
        htmlString += style          == nil ? "" : "<style>\(style!)</style>\n"
        htmlString += tableClassName == nil ? "<table>\n" : "<table class=\"\(tableClassName!)\">\n"
        
        for (indexRow, row) in array.enumerated() {
            
            if rowClassNames?.indices.contains(indexRow) ?? false, let className = rowClassNames?[indexRow] {
                htmlString += "<tr class=\"\(className)\">\n"
            } else {
                htmlString += "<tr>\n"
            }
            
            for (indexCol, coloumn) in row.enumerated() {
                
                if cellClassNames?.indices.contains(indexRow) ?? false && cellClassNames?[indexRow]?.indices.contains(indexCol) ?? false,
                    let classArray = cellClassNames?[indexRow], let className  = classArray[indexCol] {
                    htmlString += "<td class=\"\(className)\">"
                } else {
                    htmlString += "<td>"
                }
                
                htmlString += String(coloumn)
                htmlString += "</td>\n"
            }
            htmlString += "</tr>\n"
        }
        
        htmlString += "</table>"
        
        return htmlString
    }
    
    class func getTime() -> (String, String, String) {
        let date = Date()
        let hoursFormat = DateFormatter()
        hoursFormat.dateFormat = "hh"
        let minutesFormat = DateFormatter()
        minutesFormat.dateFormat = "mm"
        let dayWeeksFormat = DateFormatter()
        dayWeeksFormat.dateFormat = "EE"
        
        let hour = hoursFormat.string(from: date)
        let minute = minutesFormat.string(from: date)
      
        var dayOfWeek = ""
        
        let languageSys = Locale.preferredLanguages[0]
        if(languageSys.lowercased() != "en-us"){
            dayWeeksFormat.locale = Locale(identifier: "en-US")
        }
        let dayWeek = dayWeeksFormat.string(from: date)
        
        switch (dayWeek) {
        case "Mon":
            dayOfWeek = "2"
            break
        case "Tue":
            dayOfWeek = "3"
            break
        case "Wed":
            dayOfWeek = "4"
            break
        case "Thu":
            dayOfWeek = "5"
            break
        case "Fri":
            dayOfWeek = "6"
            break
        case "Sat":
            dayOfWeek = "7"
            break
        case "Sun":
            dayOfWeek = "CN"
            break
        default:
            break
        }
        
        return (hour, minute, dayOfWeek)
    }
    
    
    class func logout(){
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: User.COMPANY_NAME)
        defaults.removeObject(forKey: User.USER_CHECK_RADIUS)
        defaults.removeObject(forKey: User.USER_ID)
        defaults.removeObject(forKey: User.USER_CODE)
        defaults.removeObject(forKey: User.USER_FULL_NAME)
        defaults.removeObject(forKey: User.USER_AVATAR)
        defaults.removeObject(forKey: User.USER_JOB_TITLE)
        defaults.removeObject(forKey: User.MENU_SELECTED)
    }

}











