//
//  TNotification+CoreDataProperties.swift
//  
//
//  Created by MacbookPro on 11/22/19.
//
//

import Foundation
import CoreData


extension TNotification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TNotification> {
        return NSFetchRequest<TNotification>(entityName: "TNotification")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: NSDate?
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var viewed: Bool

}
