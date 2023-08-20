//
//  RequestMessage.swift
//  CabifyRider
//
//  Created by Faraz Malik on 20/08/2023.
//

import Foundation

struct RequestMessage: Codable {
    let message: String
    let read: Bool
    let sent: Date
}
