//
//  DataManager.swift
//  XWorkerBee
//
//  Created by Chan on 4/6/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import CoreData
import UIKit

@available(iOS 10.0, *)
class DataManager: NSObject{
    let T_NTF = "TNotification"
    let Cotent = "ContentPush"
    
    var appDel: AppDelegate
    var ctx: NSManagedObjectContext
    
    override init(){
        appDel = UIApplication.shared.delegate as! AppDelegate
        ctx = appDel.persistentContainer.viewContext
    }
    func addNotifyLocal(date: String){
        let etity = NSEntityDescription.entity(forEntityName: Cotent, in: ctx)
        let newRow = NSManagedObject(entity: etity!, insertInto: ctx)
        newRow.setValue(date, forKey: "date")
        do {
            try ctx.save()
            print("add notify success")
        } catch {
            print("Failed saving")
        }
    }
    func getNotifyListLocal() -> [String]{
        
        var result = [String]()
//        var result: String = ""
        let notiList: [NSManagedObject] = DataManager().getNotifyListUnreadLocal()
        if(notiList.count > 0){
            for data in notiList {
                let date = data.value(forKey: "date") as! String
                result.append(date)
            }
        }
        return result
    }
    func getNotifyListUnreadLocal() -> [NSManagedObject]{
        var notifyArr = [NSManagedObject]()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Cotent)
        do {
            let result = try ctx.fetch(request)
            notifyArr = result as! [NSManagedObject]
        } catch {
            print("Failed")
        }
        return notifyArr
    }
    func deleteNotifyLocalPush(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Cotent)
        do {
            let objects = try ctx.fetch(request)
            for object in objects {
                ctx.delete(object as! NSManagedObject)
            }
            try ctx.save()
        } catch _ {
            
        }
    }
        
    
    func addNotify(id: String, title: String, content: String, viewed: Bool) -> Bool{
        let etity = NSEntityDescription.entity(forEntityName: T_NTF, in: ctx)
        let newRow = NSManagedObject(entity: etity!, insertInto: ctx)
        
        let currentDate = Date()
        newRow.setValue(id, forKey: "id")
        newRow.setValue(title, forKey: "title")
        newRow.setValue(content, forKey: "content")
        newRow.setValue(currentDate, forKey: "date")
        newRow.setValue(viewed, forKey: "viewed")
        
        do {
            try ctx.save()
            print("add notify success")
            return true
        } catch {
            print("Failed saving")
            return false
        }
    }
    
    
    
    func getNotifyList() -> [Dictionary<String, Any>]{
        
        var result = [Dictionary<String, Any>]()
        
        let notiList: [NSManagedObject] = DataManager().getNotifyTotal()
        if(notiList.count > 0){
            for data in notiList {
                let id = data.value(forKey: "id") as! String
                let title = data.value(forKey: "title") as! String
                let content = data.value(forKey: "content") as! String
                let date = data.value(forKey: "date") as! Date
                let viewed = data.value(forKey: "viewed") as! Bool
                
                let item = ["id": id, "title": title, "content": content, "date": date, "viewed": viewed] as [String : Any]
                result.append(item)
            }
        }
        return result
    }
    
    func getNotifyListNotYetView() -> Int{
        var listTemp = [Dictionary<String, Any>]()
        
        let notiList: [NSManagedObject] = DataManager().getNotifyListUnread()
        if(notiList.count > 0){
            for data in notiList {
                let id = data.value(forKey: "id") as! String
                let title = data.value(forKey: "title") as! String
                let content = data.value(forKey: "content") as! String
                let date = data.value(forKey: "date") as! Date
                let viewed = data.value(forKey: "viewed") as! Bool
                
                let item = ["id": id, "title": title, "content": content, "date": date, "viewed": viewed] as [String : Any]
                listTemp.append(item)
            }
            return listTemp.count
        }else{
            return 0
        }
    }
    
    
    func getNotifyListUnread() -> [NSManagedObject]{
        var notifyArr = [NSManagedObject]()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: T_NTF)
        request.predicate = NSPredicate(format: "viewed = %@", "false")
        request.returnsObjectsAsFaults = false
        do {
            let result = try ctx.fetch(request)
            notifyArr = result as! [NSManagedObject]
        } catch {
            print("Failed")
        }
        return notifyArr
    }
    
    
    func getNotifyTotal() -> [NSManagedObject]{
        
        var notifyArr = [NSManagedObject]()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: T_NTF)
        
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try ctx.fetch(request)
            notifyArr = result as! [NSManagedObject]
            //            for data in result as! [NSManagedObject] {
            //                print(data.value(forKey: "recordFile") as! String)
            //                print(data.value(forKey: "callDate") as! String)
            //            }
            
        } catch {
            
            print("Failed")
        }
        
        return notifyArr
        
    }
    
    
    func updateAllNotifyViewed() -> Bool{
        
        // let request = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY_NAME_TNOTIFICATION)
        //request.predicate = NSPredicate(format: "notifyId = %@", notifyId as CVarArg)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: T_NTF)
        request.predicate = NSPredicate(format: "%K == %@", argumentArray:["viewed", false])
        request.returnsObjectsAsFaults = false
        
        var notifyRows = [NSManagedObject]()
        
        do {
            
            let result = try ctx.fetch(request)
            notifyRows = result as! [NSManagedObject]
            if(notifyRows.count != 0){
                for notifyRow in notifyRows{
                //let notifyRow = notifyRows[0]
                notifyRow.setValue(true, forKey: "viewed")
                
                do {
                    try ctx.save()
                    print("update notify success")
                    //return true
                } catch {
                    print("Failed updating")
                    //return false
                    
                }
                
                
            }
            }
            
        }catch{
            print("Failed")
            return false
        }
        return false
    }
    
    
    func updateNotifyViewed(id: String) -> Bool{
        
        // let request = NSFetchRequest<NSFetchRequestResult>(entityName: ENTITY_NAME_TNOTIFICATION)
        //request.predicate = NSPredicate(format: "notifyId = %@", notifyId as CVarArg)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: T_NTF)
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@", argumentArray:["id", id, "viewed", false])
        request.returnsObjectsAsFaults = false
        
        var notifyRows = [NSManagedObject]()
        
        do {
            
            let result = try ctx.fetch(request)
            notifyRows = result as! [NSManagedObject]
            if(notifyRows.count != 0){
                let notifyRow = notifyRows[0]
                notifyRow.setValue(true, forKey: "viewed")
                
                do {
                    try ctx.save()
                    print("update notify success")
                    return true
                } catch {
                    print("Failed updating")
                    return false
                    
                }
            }
            
        }catch{
            print("Failed")
            return false
        }
        return false
    }
    
    func deleteNotify(id: String) -> Bool{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: T_NTF)
        request.predicate = NSPredicate(format: "id == \(id)")
        do {
            let objects = try ctx.fetch(request)
            for object in objects {
                ctx.delete(object as! NSManagedObject)
            }
            try ctx.save()
            return true
        } catch _ {
            return false
        }
        return false
    }
    
}
