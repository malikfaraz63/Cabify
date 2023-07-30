//
//  JourneyDelegate.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 26/07/2023.
//

import Foundation
import CoreLocation

protocol JourneyDelegate {
    func journeyDidCompleteAtDestination(_ destination: CLLocationCoordinate2D)
}
