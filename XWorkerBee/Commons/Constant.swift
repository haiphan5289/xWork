//
//  Constant.swift
//  XWorkerBee
//
//  Created by Chan on 2/8/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import Foundation
import UIKit

struct Constant{
    
    static let BORDER_LINE_HEIGHT = CGFloat(0.3)
    static let BORDER_RADIUS = CGFloat(20)
    static let BUTTON_HEIGHT = CGFloat(50)
    static let TEXT_FIELD_HEIGHT = 35
    
    static let USER_STATUS_BLOCK = 1
    static let USER_STATUS_EXPIRE = 0
    
    static let FONT_SIZE = CGFloat(13)
    
     static let KEY_VERIFY_NEED_CHECK_IN = 1
     static let KEY_VERIFY_NO_NEED_CHECK_IN = 2
     static let KEY_VERIFY_NEED_CHECK_OUT = 3
     static let KEY_VERIFY_NO_NEED_CHECK_OUT = 4
     static let KEY_VERIFY_NOT_YET_SCHEDULE = 5
    
    static let KEY_CHECK_IN_RESULT_SUCCESS = 1
    static let KEY_CHECK_IN_RESULT_FAIL = 0
    static let KEY_CHECK_OUT_RESULT_SUCCESS = 1
    static let KEY_CHECK_OUT_RESULT_FAIL = 0
    
    static let KEY_NEED_CHECK_RADIUS = 1
    static let KEY_NO_NEED_CHECK_RADIUS = 0
    
    static let FTP_URL = "103.252.253.116"
    static let FTP_USER = "apiappchamcong"
    static let FTP_PASS = "Xep@123456789"
    static let FTP_PATH_CHECK_IN = "/mobile_picture_checkin"
    static let FTP_PATH_CHECK_OUT = "/mobile_picture_checkout"
    
    static let APPLE_USER_CODE = "digitaltrend"
    static let APPLE_USER_NAME = "apple"

}

struct User{
    static let USER_CODE = "user_code"
    static let USER_ID = "user_id"
    static let USER_NAME = "user_name"
    static let USER_FULL_NAME = "user_full_name"
    static let USER_AVATAR = "user_avatar"
    static let USER_JOB_TITLE = "user_job_title"
    static let USER_CHECK_RADIUS = "check_radius"
    static let COMPANY_NAME = "company_name"
    static let ACCOUNT_CODE = "account_code"
    static let MENU_SELECTED = "menu_selected"
    static let PLAYER_ID = "player_id"
    static let SAVE_PLAYER_ID = "save_player_id"
    static let SHOW_NOTIFICATION_BADGE_FLAG = "show_notification_badge_flag"
}

struct AddView{
    static let BUTTON_VIEW = "button_view"
}

struct Color{
    static let MAIN_COLOR = "#FB9300"
    static let WHITE_COLOR_OPPACITY_70 = "#4DFFFFFF"
    static let GREEN_COLOR = "#008000"
}

struct Log{
    static let LOG_ACTION = 0
    static let LOG_ERROR = 1
}

struct Menu{
    static let CHAM_CONG_MENU = "TimePickingViewController"
    static let XIN_NGHI_PHEP_MENU = "DayOffViewController"
    static let XIN_DI_TRE_VE_SOM_MENU = "LateViewController"
    static let BAO_CAO_MENU = "ReportViewController"
    static let NHAC_NHO_MENU = "NotificationViewController"
    static let DOI_MAT_KHAU = "ChangePassViewController"
    static let DANG_XUAT_MENU = "LoginViewController"
}



