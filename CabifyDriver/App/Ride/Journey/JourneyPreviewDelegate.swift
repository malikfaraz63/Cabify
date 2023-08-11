//
//  JourneyPreviewDelegate.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 11/08/2023.
//

import Foundation
import MapKit

protocol JourneyPreviewDelegate {
    func journeyPreviewDidSelectStep(_ step: MKRoute.Step)
    func journeyPreviewDidDismiss()
}
