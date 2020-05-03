//
//  ContentPush+CoreDataProperties.swift
//  
//
//  Created by MacbookPro on 11/22/19.
//
//

import Foundation
import CoreData


extension ContentPush {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContentPush> {
        return NSFetchRequest<ContentPush>(entityName: "ContentPush")
    }

    @NSManaged public var date: String?

}
