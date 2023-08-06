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
              case "PENDING": self = .pending
              case "ACTIVE": self = .active
              case "CANCELLED": self = .cancelled
              case "COMPLETED": self = .completed
              default: self = .unknown
          }
      }
}
