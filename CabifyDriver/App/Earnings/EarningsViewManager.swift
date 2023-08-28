//
//  EarningsUIModel.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 28/08/2023.
//

import Foundation

class EarningsViewManager: ObservableObject {
    static let weekInterval: TimeInterval = 86400 * 7
    @Published var timeCreated = EarningsClient.getWeekCommence(Date.distantPast)
    @Published var currentWeek = EarningsClient.getWeekCommence(Date())
    
    var hasPreviousWeek: Bool {
        return currentWeek.timeIntervalSince(timeCreated) >= EarningsViewManager.weekInterval
    }
    var hasNextWeek: Bool {
        return Date().timeIntervalSince(currentWeek) >= EarningsViewManager.weekInterval
    }
    
    var currentWeekDescription: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        return dateFormatter.string(from: currentWeek)
    }
    
    @Published var earningsData: [EarningsDataPoint] = []
    var totalEarnings: Double {
        return earningsData
            .map { $0.earnings }
            .reduce(0.0) { $0 + $1 }
    }
    @Published var driver: CKDriver?
    
    private let earningsClient = EarningsClient()
    
    init() {
        guard let driverId = DriverSettingsManager.getUserID() else { return }
        //let driverId = "LrAWhqjzvHbbfLmSOatLHAxTfjp1"
        
        CKProfileClient().getDriver(withDriverId: driverId) { driver in
            self.timeCreated = driver.accountCreated
            self.driver = driver
        }
        setupFromCurrentWeek()
    }
    
    // MARK: Setup Data
    
    public func setupFromCurrentWeek() {
        guard let driverId = DriverSettingsManager.getUserID() else { return }
        //let driverId = "LrAWhqjzvHbbfLmSOatLHAxTfjp1"
        
        earningsClient.getEarningsData(forDriverId: driverId, weekCommence: currentWeek, completion: setupFromEarningsData)
    }
    
    private func setupFromEarningsData(_ data: [String: Double]) {
        earningsData = []
        var newData: [EarningsWeekday: Double] = [:]
        if data.isEmpty {
            EarningsWeekday.allCases.forEach { weekday in
                newData[weekday] = 0.0
            }
        } else {
            data.forEach { key, earnings in
                newData[EarningsWeekday(rawValue: key)!] = earnings
            }
        }
        
        newData
            .sorted { $0.key < $1.key }
            .forEach { key, earnings in
                earningsData.append(EarningsDataPoint(key: key.rawValue, earnings: earnings))
            }
    }
    
    // MARK: Week Jump
    
    public func jumpForwardWeek() {
        if hasNextWeek {
            currentWeek = currentWeek.addingTimeInterval(EarningsViewManager.weekInterval)
        }
        setupFromCurrentWeek()
    }
    
    public func jumpBackWeek() {
        if hasPreviousWeek {
            currentWeek = currentWeek.addingTimeInterval(-EarningsViewManager.weekInterval)
        }
        setupFromCurrentWeek()
    }
}
