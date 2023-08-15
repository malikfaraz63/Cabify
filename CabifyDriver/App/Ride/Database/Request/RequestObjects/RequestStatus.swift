//
//  RequestStatus.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 27/07/2023.
//

import Foundation

enum RequestStatus: String, Codable {
    case pending = "PENDING"
    case active = "ACTIVE"
    case cancelled = "CANCELLED"
    case completed = "COMPLETED"
    case unknown
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)

        switch status {
        case RequestStatus.pending.rawValue: self = .pending
            case RequestStatus.active.rawValue: self = .active
            case RequestStatus.cancelled.rawValue: self = .cancelled
            case RequestStatus.completed.rawValue: self = .completed
            default: self = .unknown
        }
    }
}
