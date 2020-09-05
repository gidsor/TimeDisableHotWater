//
//  DateFormatter.swift
//  TimeDisableHotWater
//
//  Created by Vadim Denisov on 04.09.2020.
//  Copyright © 2020 Vadim Denisov. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    static var serverShoutdownPeriodFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    static var localShoutdownPeriodFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

}
