//
//  JourneyDelegate.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 26/07/2023.
//

import Foundation
import CoreLocation
import MapKit

protocol JourneyDelegate {
    func journeyDidCompleteAtDestination(_ destination: CLLocationCoordinate2D)
    func journeyDidBeginStep(_ step: MKRoute.Step)
}
