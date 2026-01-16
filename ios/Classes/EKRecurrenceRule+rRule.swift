//
//  EKRecurrenceRule+rRule.swift
//  Pods
//
//  Created by Gennady Chukin on 20.01.2025.
//

import Foundation
import EventKit

public extension EKRecurrenceRule {
    
    convenience init?(rfc5445String:String) {
        let parser = RrParser(ruleString: rfc5445String)
        
        guard let type = parser.type else {
            return nil
        }
        
        self.init(recurrenceWith:type,
                  interval:parser.interval,
                  daysOfTheWeek:parser.days,
                  daysOfTheMonth:parser.monthDays,
                  monthsOfTheYear:parser.months,
                  weeksOfTheYear:parser.weeksOfTheYear,
                  daysOfTheYear:parser.daysOfTheYear,
                  setPositions:parser.setPositions,
                  end:parser.end)
    }
    
}

fileprivate struct RrParser {
    
    init(ruleString: String) {
        self.ruleString = NSString(string: ruleString)
    }
    private let ruleString: NSString
    
    var interval: Int {
        let interval = self.ruleString.components(separatedBy: "INTERVAL=")
        
        if interval.count > 1 {
            if let intervalString = interval.last?.components(separatedBy: ";").first {
                return Int(intervalString) ?? 1
            }
        }
        
        return 1
    }
    
    var type: EKRecurrenceFrequency? {
        if self.ruleString.contains("FREQ=DAILY") {
            return .daily
        } else if self.ruleString.contains("FREQ=WEEKLY") {
            return .weekly
        } else if self.ruleString.contains("FREQ=MONTHLY") {
            return .monthly
        } else if self.ruleString.contains("FREQ=YEARLY") {
            return .yearly
        } else {
            return nil
        }
    }
    
    var end: EKRecurrenceEnd? {
        let until = self.ruleString.components(separatedBy: "UNTIL=")
        
        if until.count > 1 {
            if let recurrenceEndDateString = until.last!.components(separatedBy: ";").first {
                let recurrenceDateFormatter = DateFormatter()
                recurrenceDateFormatter.locale = Locale(identifier:"US")
                recurrenceDateFormatter.timeZone = TimeZone(identifier:"UTC")
                recurrenceDateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
                if let recurrenceEndDate = recurrenceDateFormatter.date(from: recurrenceEndDateString) {
                    return EKRecurrenceEnd(end:recurrenceEndDate)
                }
            }
        } else {
            if let count: NSNumber = processRegexp("COUNT=([\\d,-]*)")?.first {
                return EKRecurrenceEnd(occurrenceCount:count.intValue)
            }
        }
        
        return nil
    }
    
    var days: [EKRecurrenceDayOfWeek]? {
        guard let bydays: [NSString] = processRegexp("BYDAY=([\\w,]*)") else {
            return nil
        }
        
        var days = [EKRecurrenceDayOfWeek]()
        
        for byday in bydays {
            var week = byday
            var weekNumber = -1
            
            if byday.length > 2 {
                weekNumber = Int(byday.substring(with: NSRange(location:0, length:byday.length-2))) ?? -1
                week = byday.substring(with: NSRange(location:byday.length-2, length:2)) as NSString
            }
            
            var daysOfWeek: EKWeekday?
            
            switch week {
            case "MO": daysOfWeek = .monday
            case "TU": daysOfWeek = .tuesday
            case "WE": daysOfWeek = .wednesday
            case "TH": daysOfWeek = .thursday
            case "FR": daysOfWeek = .friday
            case "SA": daysOfWeek = .saturday
            case "SU": daysOfWeek = .sunday
            default: daysOfWeek = nil
            }
            
            if let _daysOfWeek = daysOfWeek {
                days.append(weekNumber > 0 ? EKRecurrenceDayOfWeek(dayOfTheWeek:_daysOfWeek, weekNumber:weekNumber) : EKRecurrenceDayOfWeek(_daysOfWeek))
            }
        }
        
        return days
    }
    
    var monthDays: [NSNumber]? {
        return processRegexp("BYMONTHDAY=([\\d,-]*)")
    }
    
    var months: [NSNumber]? {
        return processRegexp("BYMONTH=([\\d,]*)")
    }
    
    var weeksOfTheYear: [NSNumber]? {
        return processRegexp("BYWEEKNO=([\\d,-]*)")
    }
    
    var daysOfTheYear: [NSNumber]? {
        return processRegexp("BYYEARDAY=([\\d,-]*)")
    }
    
    var setPositions: [NSNumber]? {
        return processRegexp("BYSETPOS=([\\d,-]*)")
    }
    
    private func processRegexp(_ regexString: String) -> [NSString]? {
        let reg = try? NSRegularExpression(pattern:regexString, options:.caseInsensitive)
        if let match = reg?.firstMatch(in: String(self.ruleString),
                                       options:.reportProgress,
                                       range:NSRange(location:0, length:self.ruleString.length)) {
            return self.ruleString.substring(with: match.range(at: 1)).components(separatedBy: ",") as [NSString]?
        }
        return nil
    }
    
    private func processRegexp(_ regexString: String) -> [NSNumber]? {
        guard let results: [NSString] = processRegexp(regexString) else {
            return nil
        }
        return results.map { NSNumber(value: $0.intValue) }
    }
    
}
