//
//  ScheduleEntity+CoreDataProperties.swift
//  TimeDisableHotWater
//
//  Created by Vadim Denisov on 04.09.2020.
//  Copyright © 2020 Vadim Denisov. All rights reserved.
//
//

import Foundation
import CoreData


extension ScheduleEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScheduleEntity> {
        return NSFetchRequest<ScheduleEntity>(entityName: "ScheduleEntity")
    }

    @NSManaged public var address: String?
    @NSManaged public var houseNumber: String?
    @NSManaged public var housing: String?
    @NSManaged public var liter: String?
    @NSManaged public var locality: String?
    @NSManaged public var shoutdownPeriod: String?
    @NSManaged public var orderIndex: Int64
    
    func map(with schedule: Schedule) {
        locality = schedule.locality
        address = schedule.address
        houseNumber = schedule.houseNumber
        housing = schedule.housing
        shoutdownPeriod = schedule.shoutdownPeriod
    }
}
