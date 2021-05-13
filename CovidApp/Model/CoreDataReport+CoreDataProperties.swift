//
//  CoreDataReport+CoreDataProperties.swift
//  CovidApp
//
//  Created by Thien Nguyen on 27/9/20.
//  Copyright © 2020 A1_Group_3. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreDataReport {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDataReport> {
        return NSFetchRequest<CoreDataReport>(entityName: "CoreDataReport")
    }

    @NSManaged public var country: String?
    @NSManaged public var country_code: String?
    @NSManaged public var slug: String?
    @NSManaged public var new_confirmed: Int64
    @NSManaged public var total_confirmed: Int64
    @NSManaged public var new_deaths: Int64
    @NSManaged public var total_deaths: Int64
    @NSManaged public var new_recovered: Int64
    @NSManaged public var total_recovered: Int64
    @NSManaged public var date: String?

}
