//
//  DriverStatus.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 03/08/2023.
//

import Foundation

enum DriverStatus: Equatable {
    case offline
    case ready
    case viewingPendingRequest(request: PendingRequest?)
    case previewingPickup(request: ActiveRequest?)
    case travellingToPickup(request: ActiveRequest?)
    case waitingAtPickup(ride: Ride?)
    case previewingDropoff(ride: Ride?)
    case travellingToDropoff(ride: Ride?)
    
    func getRawValue() -> Int {
        switch self {
        case .offline:
            return 0
        case .ready:
            return 1
        case .viewingPendingRequest:
            return 2
        case .previewingPickup:
            return 3
        case .travellingToPickup:
            return 4
        case .waitingAtPickup:
            return 5
        case .previewingDropoff:
            return 6
        case .travellingToDropoff:
            return 7
        }
    }
    
    static func == (lhs: DriverStatus, rhs: DriverStatus) -> Bool {
        return lhs.getRawValue() == rhs.getRawValue()
    }
}
