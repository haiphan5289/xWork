//
//  Extensions.swift
//  XWorkerBee
//
//  Created by Chan on 3/28/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

import CommonCrypto

extension String {
    /**
     Get the MD5 hash of this String
     
     - returns: MD5 hash of this String
     */
    func md5() -> String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        
        for i in 0..<digestLength {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deinitialize()
        
        return String(format: hash as String)
    }
}

extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

private var handle: UInt8 = 0

extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(number: Int) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(10)
        let location = CGPoint(x: view.frame.width - (radius + CGPoint.zero.x) + 1, y: (radius + CGPoint.zero.y) - 1)
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: UIColor.red, filled: true)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = "\(number)"
        label.alignmentMode = CATextLayerAlignmentMode.center
        label.fontSize = 10
        label.frame = CGRect(origin: CGPoint(x: location.x - 6, y: location.y - 6), size: CGSize(width: 12, height: 12))
        label.foregroundColor = true ? UIColor.white.cgColor : UIColor.red.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}

extension Notification.Name {
    static let showBadge = Notification.Name("showBadge")
    static let showBadgeAtNotificationVC = Notification.Name("showBadgeAtNotificationVC")
    static let showBadgeAtDayOffVC = Notification.Name("showBadgeAtDayOffVC")
    static let showBadgeAtLateVC = Notification.Name("showBadgeAtLateVC")
    static let showBadgeAtReportVC = Notification.Name("showBadgeAtReportVC")
    static let showBadgeAtChangePassVC = Notification.Name("showBadgeAtChangePassVC")
}

public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}

extension UIViewController {
    
    var topBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    func setupNavigationBar(title: String) {
        // back button without title
        //self.navigationController?.navigationBar.topItem?.title = ""
        
        //back button color
        //self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //set titile
        self.navigationItem.title =  title
        
        //set text color & font size
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15)]
        
        //set background color without gradian effect
        self.navigationController?.navigationBar.barTintColor =  Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR) //UIColor.init(red: 134/255, green: 145/255, blue: 152/255, alpha: 1)
        
        let leftButton = UIBarButtonItem(image: UIImage(named: "ic_logo35pt_full")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: nil)
        //show right button
        let rightButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_logout28pt"), style: .plain, target: self, action: #selector(logoutMenuAction))
        
        //right Bar Button Item tint color
        //self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
        
        //show the Menu button item
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.rightBarButtonItem = rightButton
        
        //let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_logo"), style: .plain, target: self, action: nil)
        //self.navigationItem.leftBarButtonItem = leftButton
        
        //show bar button item tint color
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white  //UIColor.init(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
        
    }
    
    @objc func logoutMenuAction(){
        Utils.logout()
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let lvc = storyBoard.instantiateViewController(withIdentifier: "idLoginVC") as! LoginViewController
        lvc.modalPresentationStyle = .fullScreen
        self.present(lvc, animated: true, completion: nil)
    }
    
    func setNavTitleImage1(_ title: String, andImage image: UIImage) {
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.textColor = UIColor.white
        titleLbl.font = UIFont.systemFont(ofSize: 18)
        let imageView = UIImageView(image: image)
        let titleView = UIStackView(arrangedSubviews: [imageView, titleLbl])
        titleView.axis = .horizontal
        titleView.spacing = 10.0
        navigationItem.titleView = titleView
        
        //set titile
        //self.navigationItem.title =  title
        
        //set text color & font size
        //            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 19)]
        
        //set background color without gradian effect
        self.navigationController?.navigationBar.barTintColor =  Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR) //UIColor.init(red: 134/255, green: 145/255, blue: 152/255, alpha: 1)
        
        //show right button
        let rightButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_logout28pt"), style: .plain, target: self, action: #selector(logoutMenuAction))
        
        //right Bar Button Item tint color
        //self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
        
        //show the Menu button item
        self.navigationItem.rightBarButtonItem = rightButton
        
        //let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_logo"), style: .plain, target: self, action: nil)
        //self.navigationItem.leftBarButtonItem = leftButton
        
        //show bar button item tint color
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white  //UIColor.init(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
    }
    
    
    
    func setNavTitleImage(title: String, image: UIImage){
        // Create a navView to add to the navigation bar
        let navView = UIView()
        
        // Create the label
        let label = UILabel()
        label.text = title
        label.sizeToFit()
        label.center = navView.center
        label.textAlignment = .center
        
        // Create the image view
        let image = UIImageView(image: image)
        // To maintain the image's aspect ratio:
        let imageAspect = image.image!.size.width/image.image!.size.height
        // Setting the image frame so that it's immediately before the text:
        image.frame = CGRect(x: label.frame.origin.x-label.frame.size.height*imageAspect, y: label.frame.origin.y, width: label.frame.size.height*imageAspect, height: label.frame.size.height)
        image.contentMode = UIView.ContentMode.scaleAspectFit
        
        // Add both the label and image view to the navView
        navView.addSubview(label)
        navView.addSubview(image)
        
        // Set the navigation bar's navigation item's titleView to the navView
        self.navigationItem.titleView = navView
        
        //set background color without gradian effect
        self.navigationController?.navigationBar.barTintColor =  Utils.convertHexStringToUIColor(hex: Color.MAIN_COLOR) //UIColor.init(red: 134/255, green: 145/255, blue: 152/255, alpha: 1)
        
        //show right button
        let rightButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_logout28pt"), style: .plain, target: self, action: #selector(logoutMenuAction))
        
        //right Bar Button Item tint color
        //self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
        
        //show the Menu button item
        self.navigationItem.rightBarButtonItem = rightButton
        
        //let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_logo"), style: .plain, target: self, action: nil)
        //self.navigationItem.leftBarButtonItem = leftButton
        
        //show bar button item tint color
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white  //UIColor.init(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
        
        // Set the navView's frame to fit within the titleView
        navView.sizeToFit()
        
        
    }
}



extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}


extension UIView {
    
    var heightConstaint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .height && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }
    }
    
    var widthConstaint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .width && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }
    }
    
}



enum ScrollDirection {
    case Top
    case Right
    case Bottom
    case Left
    
    func contentOffsetWith(scrollView: UIScrollView) -> CGPoint {
        var contentOffset = CGPoint.zero
        switch self {
        case .Top:
            contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
        case .Right:
            contentOffset = CGPoint(x: scrollView.contentSize.width - scrollView.bounds.size.width, y: 0)
        case .Bottom:
            contentOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        case .Left:
            contentOffset = CGPoint(x: -scrollView.contentInset.left, y: 0)
        }
        return contentOffset
    }
}


extension UIScrollView {
    func scrollTo(direction: ScrollDirection, animated: Bool = true) {
        self.setContentOffset(direction.contentOffsetWith(scrollView: self), animated: animated)
    }
}



//extension UILabel {
//    private struct AssociatedKeys {
//        static var padding = UIEdgeInsets()
//    }
//
//    public var padding: UIEdgeInsets? {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
//        }
//        set {
//            if let newValue = newValue {
//                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            }
//        }
//    }
//
//    override open func draw(_ rect: CGRect) {
//        if let insets = padding {
//            self.drawText(in: rect.inset(by: insets))
//        } else {
//            self.drawText(in: rect)
//        }
//    }
//
//    override open var intrinsicContentSize: CGSize {
//        guard let text = self.text else { return super.intrinsicContentSize }
//
//        var contentSize = super.intrinsicContentSize
//        var textWidth: CGFloat = frame.size.width
//        var insetsHeight: CGFloat = 0.0
//        var insetsWidth: CGFloat = 0.0
//
//        if let insets = padding {
//            insetsWidth += insets.left + insets.right
//            insetsHeight += insets.top + insets.bottom
//            textWidth -= insetsWidth
//        }
//
//        let newSize = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
//                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
//                                        attributes: [NSAttributedString.Key.font: self.font], context: nil)
//
//        contentSize.height = ceil(newSize.size.height) + insetsHeight
//        contentSize.width = ceil(newSize.size.width) + insetsWidth
//
//        return contentSize
//    }
//}

