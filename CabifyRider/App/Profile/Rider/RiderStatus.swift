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
    case previewingSelectedRoute(rideCost: Double)
    case awaitingRequestAcceptance(request: PendingRequest)
    case awaitingDriverArrival(request: ActiveRequest)
    
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
        case .awaitingRequestAcceptance:
            return 4
        case .awaitingDriverArrival:
            return 5
        }
    }
    
    static func ==(lhs: RiderStatus, rhs: RiderStatus) -> Bool {
        return lhs.getValue() == rhs.getValue()
    }
}
