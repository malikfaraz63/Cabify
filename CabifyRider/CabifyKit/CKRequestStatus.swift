//
//  RequestStatus.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 27/07/2023.
//

import Foundation

enum CKRequestStatus: String, Codable {
    case pending = "PENDING"
    case active = "ACTIVE"
    case cancelled = "CANCELLED"
    case completed = "COMPLETED"
    case unknown
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try? container.decode(String.self)

        switch status {
        case CKRequestStatus.pending.rawValue: self = .pending
            case CKRequestStatus.active.rawValue: self = .active
            case CKRequestStatus.cancelled.rawValue: self = .cancelled
            case CKRequestStatus.completed.rawValue: self = .completed
            default: self = .unknown
        }
    }
}
