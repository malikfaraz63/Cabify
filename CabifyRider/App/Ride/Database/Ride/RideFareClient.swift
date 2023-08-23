//
//  RideCostCalculator.swift
//  CabifyRider
//
//  Created by Faraz Malik on 18/08/2023.
//

import Foundation

class RideFareClient {
    
    typealias CostCompletion = (Double) -> Void

    static func getCostForJourney(pickup: CKCoordinate, dropoff: CKCoordinate) -> Double {
        let distance = CKMapUtility.getDistanceBetweenCoordinates(pickup, dropoff)
        
        return distance * 0.004
    }
}
