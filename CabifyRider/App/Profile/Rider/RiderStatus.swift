//
//  RiderStatus.swift
//  CabifyRider
//
//  Created by Faraz Malik on 14/08/2023.
//

import Foundation

enum RiderStatus: Equatable {
    case usingRouteSelector
    case pinSelectingPickup(locationDescription: String?)
    case pinSelectingDropoff(locationDescription: String?)
    case previewingSelectedRoute
    
    private func getValue() -> Int {
        switch self {
        case .usingRouteSelector:
            return 0
        case .pinSelectingPickup:
            return 1
        case .pinSelectingDropoff:
            return 2
        case .previewingSelectedRoute:
            return 3
        }
    }
    
    static func ==(lhs: RiderStatus, rhs: RiderStatus) -> Bool {
        return lhs.getValue() == rhs.getValue()
    }
}
