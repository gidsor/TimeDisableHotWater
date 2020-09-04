//
//  Schedule.swift
//  TimeDisableHotWater
//
//  Created by Vadim Denisov on 03.09.2020.
//  Copyright © 2020 Vadim Denisov. All rights reserved.
//

import Foundation

struct Schedule: Codable {
    
    let locality: String
    let address: String
    let houseNumber: String
    let housing: String
    let liter: String
    let shoutdownPeriod: String
    
    enum CodingKeys: String, CodingKey {
        case locality = "Населенный пункт"
        case address = "Адрес жилого здания"
        case houseNumber = "№ дома"
        case housing = "корпус"
        case liter = "литер"
        case shoutdownPeriod = "Период отключения ГВС"
    }
    
    init(from entity: ScheduleEntity) {
        locality = entity.locality ?? ""
        address = entity.address ?? ""
        houseNumber = entity.houseNumber ?? ""
        housing = entity.housing ?? ""
        liter = entity.liter ?? ""
        shoutdownPeriod = entity.shoutdownPeriod ?? ""
    }
}
