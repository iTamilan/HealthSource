//
//  DBT_HSSample+CoreDataProperties.swift
//  HealthSource
//
//  Created by Tamilarasu on 15/10/17.
//  Copyright © 2017 Tamilarasu Ponnusamy. All rights reserved.
//
//

import Foundation
import CoreData


extension DBT_HSSample {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBT_HSSample> {
        return NSFetchRequest<DBT_HSSample>(entityName: "DBT_HSSample")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var data: NSObject?

}
