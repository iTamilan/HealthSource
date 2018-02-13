//
//  HSDateRange.swift
//  HealthSource
//
//  Created by Tamilarasu on 10/02/18.
//  Copyright © 2018 Tamilarasu. All rights reserved.
//

import Foundation


struct DateRange {
    var fromDate:Date
    var toDate:Date{
        didSet{
            isToDateIsNow = toDate.timeIntervalSinceNow > -60
        }
    }
    var days:UInt
    var isToDateIsNow:Bool
    init(fromDate:Date, toDate:Date) {
        self.fromDate = fromDate
        self.toDate = toDate
        self.isToDateIsNow = self.toDate.timeIntervalSinceNow > -60
        self.days = UInt(toDate.interval(ofComponent: .day, fromDate: fromDate))
    }
    init(lastDays:UInt) {
        self.days = lastDays
        self.toDate = Date()
        self.fromDate = Calendar.current.date(byAdding: .day, value: -Int(lastDays), to: Calendar.current.startOfDay(for: Date()))!
        self.isToDateIsNow = true
    }
    func displayText() -> String {
        var displayString = "\(self.fromDate.dateTimeString())"
        if self.isToDateIsNow {
            displayString.append(" to Now")
        }else{
               displayString.append(" to \n\(self.toDate.dateTimeString())")
        }
        return displayString
    }
    
}
