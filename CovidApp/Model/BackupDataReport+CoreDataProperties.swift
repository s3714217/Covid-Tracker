//
//  BackupDataReport+CoreDataProperties.swift
//  CovidApp
//
//  Created by Geoffrey Chan on 6/10/20.
//  Copyright © 2020 A1_Group_3. All rights reserved.
//
//

import Foundation
import CoreData


extension BackupDataReport {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BackupDataReport> {
        return NSFetchRequest<BackupDataReport>(entityName: "BackupDataReport")
    }

    @NSManaged public var total_recovered: Int64
    @NSManaged public var total_deaths: Int64
    @NSManaged public var total_confirmed: Int64
    @NSManaged public var slug: String?
    @NSManaged public var new_recovered: Int64
    @NSManaged public var new_deaths: Int64
    @NSManaged public var new_confirmed: Int64
    @NSManaged public var date: String?
    @NSManaged public var country_code: String?
    @NSManaged public var country: String?

}
