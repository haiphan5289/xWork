//
//  ExtensionTimePickingVC.swift
//  XWorkerBee
//
//  Created by HaiPhan on 10/30/19.
//  Copyright © 2019 XEP. All rights reserved.
//
import UIKit

extension TimePickingViewController {
    
    func addSlideMenuButtonTimePicking(allViewed: Bool, countNotView: Int){
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
}

extension String {
    func convertToDate(text: String) -> Date {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        let date = dateFormatter.date(from:text)
        return date ?? currentDate
    }
}
