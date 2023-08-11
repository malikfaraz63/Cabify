//
//  RequestMessage.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 01/08/2023.
//

import Foundation

struct RequestMessage: Codable {
    let message: String
    let read: Bool
    let sent: Date
}
