//
//  EarningsClient.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 24/08/2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class EarningsClient {
    let db = Firestore.firestore()
    let dateFormatter = DateFormatter()
    
    public func getEarningsData(forDriverId driverId: String, weekCommence: Date, completion: @escaping ([String: Double]) -> Void) {
        dateFormatter.dateFormat = "YYYY"
        let yearString = dateFormatter.string(from: weekCommence)
        dateFormatter.dateFormat = "MM"
        let monthString = dateFormatter.string(from: weekCommence)
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let weekString = dateFormatter.string(from: weekCommence)
        
        let ref = db
            .collection("drivers").document(driverId)
            .collection("earningsYears").document(yearString)
            .collection("earningsMonths").document(monthString)
            .collection("earningsWeeks").document(weekString)
        
        ref
            .getDocument(as: [String: Double].self) { result in
                switch result {
                case .success(let data):
                    completion(data)
                case .failure(let error):
                    completion([:])
                    print(error)
                }
            }
    }
    
    public func updateEarningsData(forDriverId driverId: String, cost: Double) {
        let date = EarningsClient.getWeekCommence(Date())
        
        dateFormatter.dateFormat = "YYYY"
        let yearString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MM"
        let monthString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let weekString = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "EEE"
        let weekdayString = dateFormatter.string(from: Date())
        
        var ref = db
            .collection("drivers").document(driverId)
            .collection("earningsYears").document(yearString)
        updateEarningsData(forReference: ref, summaryKey: yearString, cost: cost)
        
        ref = ref
            .collection("earningsMonths").document(monthString)
        updateEarningsData(forReference: ref, summaryKey: monthString, cost: cost)
        
        ref = ref
            .collection("earningsWeeks").document(weekString)
        updateEarningsData(forReference: ref, summaryKey: weekString, cost: cost)
        
        ref.getDocument { documentSnapshot, error in
            if let documentSnapshot = documentSnapshot {
                if documentSnapshot.exists {
                    if let previousCost = documentSnapshot.data()?[weekdayString] as? Double {
                        ref.updateData([weekdayString: previousCost + cost])
                    } else {
                        ref.setData([weekdayString: cost])
                    }
                } else {
                    ref.setData([weekdayString: cost])
                }
            } else if let error = error {
                print(error)
            }
        }
    }
    
    public static func getWeekCommence(_ date: Date) -> Date {
        guard let weekdayWrapper = Calendar.current.dateComponents([.weekday], from: date).weekday else { fatalError() }
        
        if weekdayWrapper == 1 {
            return getWeekCommence(date.advanced(by: -86400))
        }
        
        let weekday = weekdayWrapper - 2
        
        return date.advanced(by: Double(-86400 * weekday))
    }
    
    private func updateEarningsData(forReference reference: DocumentReference, summaryKey: String, cost: Double) {
        reference.getDocument { documentSnapshot, error in
            if let documentSnapshot = documentSnapshot {
                let key = "summary.\(summaryKey)"
                if documentSnapshot.exists {
                    if let previousCost = documentSnapshot.data()?[key] as? Double  {
                        reference.updateData([key: previousCost + cost])
                    } else {
                        reference.updateData([key: cost])
                    }
                } else {
                    reference.setData([key: cost])
                }
            } else if let error = error {
                print(error)
            }
        }
    }
}
