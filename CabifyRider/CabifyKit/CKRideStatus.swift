//
//  RideStatus.swift
//  CabifyRider
//
//  Created by Faraz Malik on 21/08/2023.
//

import Foundation

enum CKRideStatus: String, Codable {
    case active = "ACTIVE"
    case waiting = "WAITING"
    case completed = "COMPLETED"
    case unknown
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)
        switch status {
            case "ACTIVE": self = .active
            case "WAITING": self = .waiting
            case "COMPLETED": self = .completed
            default: self = .unknown
        }
    }
}
