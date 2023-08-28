//
//  EarningsWeekData.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 24/08/2023.
//

import Foundation

struct EarningsWeekData {
    let data: [EarningsWeekdayData]
    
    public init(from data: [String: Double]) {
        var holder: [EarningsWeekdayData] = []
        for (key, value) in data {
            if let weekday = EarningsWeekday(rawValue: key) {
                let weekdayData = EarningsWeekdayData(weekday: weekday, earnings: value)
                holder.append(weekdayData)
            }
        }
        
        self.data = holder.sorted { $0.weekday < $1.weekday }
    }
}

enum EarningsWeekday: String, Equatable, Comparable, CaseIterable {
    case monday    = "Mon"
    case tuesday   = "Tue"
    case wednesday = "Wed"
    case thursday  = "Thu"
    case friday    = "Fri"
    case saturday  = "Sat"
    case sunday    = "Sun"
    
    func getValue() -> Int {
        switch self {
        case .monday:
            return 0
        case .tuesday:
            return 1
        case .wednesday:
            return 2
        case .thursday:
            return 3
        case .friday:
            return 4
        case .saturday:
            return 5
        case .sunday:
            return 6
        }
    }
    
    static func < (lhs: EarningsWeekday, rhs: EarningsWeekday) -> Bool {
        return lhs.getValue() < rhs.getValue()
    }
}
struct EarningsWeekdayData: Identifiable {
    let weekday: EarningsWeekday
    let earnings: Double
    
    var id: String { weekday.rawValue }
}
