
import Foundation
private let onlyDateFormatString = "dd MMM, yy"
private let onlyTimeFormatString = "hh:mm a"
private let dateTimeFormatString = "ddMMMyy hh:mm a"
private let monthAndYearDateFormatter = "MMM,yy"

extension Date {

    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
    
    func onlyDateString() -> String {
        let calendar = Calendar.current
        let dateComponents = calendar.component(.day, from: self)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        let day = numberFormatter.string(from: dateComponents as NSNumber)
        let dateFormatter = HSDateFormatter.shared.mothYearFormatter
        let dateString = "\(day!) \(dateFormatter.string(from: self))"
        return dateString
    }
    
    func onlyTimeString() -> String {
        return HSDateFormatter.shared.onlyTimeFormatter.string(from: self)
    }
    
    func dateTimeString() -> String {
        return "\(self.onlyDateString()) \(self.onlyTimeString())"
    }
    
}

class HSDateFormatter {
    static let shared = HSDateFormatter()
    lazy var onlyDateFormatter: DateFormatter = {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = onlyDateFormatString
        return dateFormatter
    }()
    lazy var onlyTimeFormatter: DateFormatter = {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = onlyTimeFormatString
        return dateFormatter
    }()
    lazy var dateTimeFormatter: DateFormatter = {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateTimeFormatString
        return dateFormatter
    }()
    lazy var mothYearFormatter: DateFormatter = {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = monthAndYearDateFormatter
        return dateFormatter
    }()
    
}
