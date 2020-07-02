//
//  RequestManager.swift
//  XWorkerBee
//
//  Created by Chan on 2/8/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct ApiUrl{
    static let BASE_API_URL = "https://api.xworkerbee.vn/api/chamcong"
}

struct ApiConfig{
    static let TIMEOUT_INTERVAL = 30
}

public class RequestManager {
    
    class func postRequestWithFile(url: String, imageData: Data?, fileName: String, parameters: Dictionary<String, Any>, onCompletion: @escaping (_ requestURL: String, _ responseBody: JSON) -> Void){
        
        /* https://medium.com/swift2go/alamofire-4-multipart-file-upload-with-swift-3-174df1ef84c1 */
        let headers: HTTPHeaders = [
            /* "Authorization": "your_access_token",  in case you need authorization header */
            "Content-type": "multipart/form-data"
        ]
        
        let sm = Alamofire.SessionManager.default
        sm.session.configuration.timeoutIntervalForRequest = TimeInterval(ApiConfig.TIMEOUT_INTERVAL)
        sm.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData{
                multipartFormData.append(data, withName: "image", fileName: fileName, mimeType: "image/jpg")
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    //                    print("Succesfully uploaded")
                    //                    //                    if let err = response.error{
                    //                    //                        onError?(err)
                    //                    //                        return
                    //                    //                    }
                    //                    let swiftyJsonVar = JSON(response.result.value!)
                    //                    onCompletion(swiftyJsonVar)
                    
                    print("------------ API REQUEST ---------")
                    print(response.request?.url!)
                    print("//Method: POST With File")
                    print("//Parameters")
                    print("\(parameters)")
                    print("----------------------------------")
                    print("                             ")
                    
                    if((response.result.value) != nil) {
                        let swiftyJsonVar = JSON(response.result.value!)
                        print("------------ API RESPONSE ---------")
                        print("Body")
                        print("\(swiftyJsonVar)")
                        print("-----------------------------------")
                        do {
                            onCompletion("", swiftyJsonVar)
                        }catch{
                        }
                    }else{
                        onCompletion("", "error")
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                //onError?(error)
                if error._code == NSURLErrorTimedOut{
                    onCompletion("", "timeout")
                }else{
                    onCompletion("", "error")
                }
            }
        }
    }
    
    
    class func postRequest(url: String, parameters: Dictionary<String, Any>, postCompleted: @escaping (JSON) -> Void){
        Alamofire.request(ApiUrl.BASE_API_URL + url, method: .post, parameters: parameters, encoding: URLEncoding(destination: .methodDependent))
            .responseJSON { response in
                if((response.result.value) != nil) {
                    let swiftyJsonVar = JSON(response.result.value!)
                    print("------------ API RESPONSE ---------")
                    print("//")
                    print("//Method: POST")
                    print("//")
                    print("//")
                    print("//Parameters")
                    print("\(parameters)")
                    print("//")
                    print("\(swiftyJsonVar)")
                    print("-----------------------------------")
                    postCompleted(swiftyJsonVar)
                }else{
                    postCompleted("error")
                }
        }
    }
    
    
    class func getRequest(url: String, parameters: Dictionary<String, Any>, postCompleted: @escaping (_ requestURL: String, _ responseBody: JSON) -> Void){
        if(Utils.isConnectedToNetwork()){
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = TimeInterval(ApiConfig.TIMEOUT_INTERVAL)
            let sessionManager = Alamofire.SessionManager(configuration: configuration)
            sessionManager.request(ApiUrl.BASE_API_URL + url, method: .get, parameters: parameters, encoding: URLEncoding(destination: .methodDependent))
                .responseJSON { response in
                    let _ = sessionManager
                    print("------------ API REQUEST ---------")
                    print(response.request?.url! as Any)
                    print("//Method: GET")
                    print("//Parameters")
                    print("\(parameters)")
                    print("----------------------------------")
                    print("")
                    let requestUrl = String(describing: response.request?.url!)
                    
                    switch (response.result){
                    case .success:
                        if((response.result.value) != nil) {
                            let swiftyJsonVar = JSON(response.result.value!)
                            print("------------ API RESPONSE ---------")
                            print("Body")
                            print("\(swiftyJsonVar)")
                            print("-----------------------------------")
                            postCompleted(requestUrl, swiftyJsonVar)
                        }else{
                            if(response.result.value == nil || (response.result.value != nil && response.result.value as! String == "")){
                                postCompleted(requestUrl, "error")
                            }
                        }
                        break
                    case .failure(let error):
                        if error._code == NSURLErrorTimedOut{
                            postCompleted(requestUrl, "timeout")
                        }else{
                            postCompleted(requestUrl, "error")
                        }
                        break
                    }
            }
            
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "idNetworkVC") as! NetworkViewController
            //self.present(controller, animated: true, completion: nil)
            if let window = UIApplication.shared.delegate?.window {
                if let viewController = window?.rootViewController {
                    viewController.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    class func login(userCode: String, userName: String, password: String, infoDevice: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["MaTaiKhoan":userCode, "TenDangNhap": userName, "MatKhau": password, "ThongSoMay": infoDevice]
        getRequest(url: "", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                if(response == "timeout"){
                    completionHandler(false, "timeout")
                }else{
                    if(response == "error"){
                        completionHandler(false, "error")
                    }else{
                        completionHandler(true, response)
                    }
                }
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    class func isAccountValid(userCode: String, infoDevice: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien":userCode,"ThongSoMay": infoDevice]
        getRequest(url: "/getTaiKhoanHopLe", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                if(response == "timeout"){
                    completionHandler(false, "timeout")
                }else{
                    if(response == "error"){
                        completionHandler(false, "error")
                    }else{
                        completionHandler(true, response)
                    }
                }
            }else{
                completionHandler(false, "error")
            }
        })
    }

    
    
    class func getUserStatus(userId: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["IsidNhanVien":userId]
        getRequest(url: "", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    
    class func changePassword(userId: String, oldPass: String, newPass: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien":userId, "PassCu": oldPass, "PassMoi": newPass]
        getRequest(url: "", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    class func dayOff(userId: String, reasonId: String, fromDate: String, toDate: String, content: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien":userId, "idLyDoNghi": reasonId, "TuNgay": fromDate, "DenNgay": toDate, "NoiDung": content]
        getRequest(url: "/YeuCauNghi", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    class func ScheduleOff(idSchedule: String, userId: String, reasonId: String, fromDate: String, toDate: String, content: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idCa":idSchedule,"idNhanVien":userId, "idLyDoNghi": reasonId, "TuNgay": fromDate, "DenNgay": toDate, "NoiDung": content]
        getRequest(url: "/YeuCauNghiTheoCa", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    class func lateOff(userId: String, reasonId: String, lateDate: String, typeLate: String, hour: String, minute: String, content: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien":userId, "idLyDoDiTreVeSom": reasonId, "Ngay": lateDate, "Loai": typeLate, "NoiDung": content, "Gio": hour, "Phut": minute]
        getRequest(url: "/XinDiTreVeSom", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    class func lateOffSchedule(idShedule: String, userId: String, reasonId: String, lateDate: String, typeLate: String, hour: String, minute: String, content: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idCa": idShedule,"idNhanVien":userId, "idLyDoDiTreVeSom": reasonId, "Ngay": lateDate, "Loai": typeLate, "NoiDung": content, "Gio": hour, "Phut": minute]
        getRequest(url: "/XinDiTreVeSomTheoCa", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    class func determine(userId: String, completionHandler: @escaping (_ url: String, _ status: Bool,_ message: JSON) -> Void){
//        let parameters = ["idNhanVien":userId, "MaThu": day, "Gio": hours, "Phut": minutes]
        let parameters = ["_idNhanVien":userId]
        getRequest(url: "/XacDinhThongTinNhanVienVersion2", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                if(response == "timeout"){
                    completionHandler(url, false, "timeout")
                }else{
                    if(response == "error"){
                        completionHandler(url, false, "error")
                    }else{
                        completionHandler(url, true, response)
                    }
                }
            }else{
                completionHandler(url, false, "error")
            }
        })
    }
    class func determineSchedule(userId: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien":userId]
        getRequest(url: "/XacDinhCaTiepTheoCuaNhanVien", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                if(response == "timeout"){
                    completionHandler( false, "timeout")
                }else{
                    if(response == "error"){
                        completionHandler( false, "error")
                    }else{
                        completionHandler(true, response)
                    }
                }
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    class func listScheduleStaff(userId: String, fromDate: String, toDate: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void) {
        let parameters = ["idNhanVienVanPhong":userId, "TuNgay": fromDate, "DenNgay": toDate]
        getRequest(url: "/LayRaCaTheoNgayCuaNhanVien", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                if(response == "timeout"){
                    completionHandler( false, "timeout")
                }else{
                    if(response == "error"){
                        completionHandler( false, "error")
                    }else{
                        completionHandler(true, response)
                    }
                }
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
//    class func listScheduleDayStaff(userId: String, toDate: String, fromDate: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
//        let parameters = ["idNhanVien":userId, "TuNgay": toDate, "DenNgay": fromDate]
//        getRequest(url: "/LayRaCaTheoNgayCuaNhanVien", parameters: parameters, postCompleted: {(url, response) -> Void in
//            if(response != ""){
//                if(response == "timeout"){
//                    completionHandler( false, "timeout")
//                }else{
//                    if(response == "error"){
//                        completionHandler( false, "error")
//                    }else{
//                        completionHandler(true, response)
//                    }
//                }
//            }else{
//                completionHandler(false, "error")
//            }
//        })
//    }
    
    class func getLocationByUser(userId: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["_idNhanVien":userId]
        getRequest(url: "", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    class func checkInV2(imageData: Data?, fileName: String, userId: String, log: Double, lat: Double, completionHandler: @escaping (_ url: String, _ status: Bool,_ message: JSON) -> Void){
        let parameters = ["IDNhanVien": userId, "_KinhDo": log, "_ViDo": lat] as [String : Any]
        postRequestWithFile(url: ApiUrl.BASE_API_URL + "/InsertCheckInVersion2", imageData: imageData, fileName: fileName, parameters: parameters, onCompletion: {(url, response) -> Void in
            if(response != ""){
                if(response == "timeout"){
                    completionHandler(url, false, "timeout")
                }else{
                    if(response == "error"){
                        completionHandler(url, false, "error")
                    }else{
                        completionHandler(url, true, response)
                    }
                }
            }else{
                completionHandler(url, false, "error")
            }
        })
    }
    
    class func newCheck(imageData: Data?, fileName: String, userId: String, idCa: String, log: Double, lat: Double, completionHandler: @escaping (_ url: String, _ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien": userId, "idCa": idCa, "KinhDo": log, "ViDo": lat] as [String : Any]
        postRequestWithFile(url: ApiUrl.BASE_API_URL + "/Checkin", imageData: imageData, fileName: fileName, parameters: parameters, onCompletion: {(url, response) -> Void in
            if(response != ""){
                if(response == "timeout"){
                    completionHandler(url, false, "timeout")
                }else{
                    if(response == "error"){
                        completionHandler(url, false, "error")
                    }else{
                        completionHandler(url, true, response)
                    }
                }
            }else{
                completionHandler(url, false, "error")
            }
        })
    }
    
    
    class func checkIn(userId: String, log: Double, lat: Double, fileName: String, completionHandler: @escaping (_ url: String, _ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien":userId, "KinhDo": log, "ViDo": lat, "chuoianh": fileName] as [String : Any]
        getRequest(url: "", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(url, true, response)
            }else{
                completionHandler(url, false, "error")
            }
        })
    }
    
    class func checkOutV2(imageData: Data?, fileName: String, userId: String, log: Double, lat: Double, completionHandler: @escaping (_ url: String, _ status: Bool,_ message: JSON) -> Void){
        let parameters = ["IDNhanVien": userId, "_KinhDo": log, "_ViDo": lat] as [String : Any]
        postRequestWithFile(url: ApiUrl.BASE_API_URL + "/InsertCheckOutVersion2", imageData: imageData, fileName: fileName, parameters: parameters, onCompletion: {(url, response) -> Void in
            if(response != ""){
                completionHandler(url, true, response)
            }else{
                completionHandler(url, false, response)
            }
        })
    }
    
    class func newCheckOut(imageData: Data?, fileName: String, userId: String, idCa: String, log: Double, lat: Double, completionHandler: @escaping (_ url: String, _ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien": userId, "idCa": idCa, "KinhDo": log, "ViDo": lat] as [String : Any]
        postRequestWithFile(url: ApiUrl.BASE_API_URL + "/Checkout", imageData: imageData, fileName: fileName, parameters: parameters, onCompletion: {(url, response) -> Void in
            if(response != ""){
                completionHandler(url, true, response)
            }else{
                completionHandler(url, false, response)
            }
        })
    }
    
    class func checkOut(userId: String, log: Double, lat: Double, fileName: String, completionHandler: @escaping (_ url: String, _ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien":userId, "KinhDo1": log, "ViDo1": lat, "chuoianh1": fileName] as [String : Any]
        getRequest(url: "", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(url, true, response)
            }else{
                completionHandler(url, false, "error")
            }
        })
    }
    
    class func report(userId: String, month: String, year: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien_Input":userId, "Thang": month, "Nam": year] as [String : Any]
        getRequest(url: "/XuatBaoCaoThang", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    class func reportDetail(userId: String, month: String, year: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien":userId, "Thang": month, "Nam": year] as [String : Any]
        getRequest(url: "/BaoCaoChiTiet", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    
    
    class func getReasons(completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["":""]
        getRequest(url: "/DanhSachLyDoNghi", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    class func getReasonLate(completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["":""]
        getRequest(url: "/DanhSachLyDoDiTreVeSom", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    class func setPlayerID(userID: String, playerID: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien":userID, "deviceid": playerID]
        getRequest(url: "/CapNhatDevice", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    class func updateNotificationStatus(userID: String, notificationID: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien":userID, "notification_id": notificationID]
        getRequest(url: "/CapNhatThongBao", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    class func updateListNotificationStatus(userID: String, notificationID: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien":userID, "id": notificationID]
        getRequest(url: "/CapNhatThongBaoVersion2", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    class func getNotificationList(userID: String, completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["idNhanVien":userID]
        getRequest(url: "/LayThongBao", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    class func getVersion(completionHandler: @escaping (_ status: Bool,_ message: JSON) -> Void){
        let parameters = ["":""]
        getRequest(url: "/GetVersion", parameters: parameters, postCompleted: {(url, response) -> Void in
            if(response != ""){
                completionHandler(true, response)
            }else{
                completionHandler(false, "error")
            }
        })
    }
    
    class func insertLog(userId: String,
                         deviceType: String,
                         flatForm: String,
                         logType: Int,
                         logMessage: String,
                         logDescription: String,
                         completionHandler: (() -> Void)? = nil){
        let parameters = ["UserId":userId,
                          "DeviceType": deviceType,
                          "FlatForm": flatForm,
                          "LogType": logType,
                          "LogMessage": logMessage,
                          "Description": logDescription] as [String : Any]
        getRequest(url: "", parameters: parameters, postCompleted: {(url, response) -> Void in
        })
    }
    
    
}
