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
    case waitingAtPickup
    case previewingDropoff
    case travellingToDropoff
    
    func getRawValue() -> Int {
        switch self {
        case .offline:
            return 0
        case .ready:
            return 1
        case .viewingPendingRequest(_):
            return 2
        case .previewingPickup(_):
            return 3
        case .travellingToPickup(_):
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
