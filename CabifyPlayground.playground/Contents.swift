import Foundation

let date = Date()
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "YYYY"
let yearString = dateFormatter.string(from: date)
dateFormatter.dateFormat = "MMM"
let monthString = dateFormatter.string(from: date)
dateFormatter.dateFormat = "YY-MM-dd"
let weekString = dateFormatter.string(from: date)
dateFormatter.dateFormat = "EEE"
let weekdayString = dateFormatter.string(from: Date())

func getWeekCommence(_ date: Date) -> Date {
    guard let weekdayWrapper = Calendar.current.dateComponents([.weekday], from: date).weekday else { fatalError() }
    
    if weekdayWrapper == 1 {
        return getWeekCommence(date.advanced(by: -86400))
    }
    
    let weekday = weekdayWrapper - 2
    
    return date.advanced(by: Double(-86400 * weekday))
}

dateFormatter.dateFormat = "YYYY-MM-dd"
dateFormatter.string(from: getWeekCommence(Date().addingTimeInterval(-200000)))
