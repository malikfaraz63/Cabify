//
//  PendingRequestDelegate.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 26/07/2023.
//

import Foundation

protocol PendingRequestDelegate {
    func didTryToAcceptRequest(_ request: PendingRequest)
    func requestTimedOut(_ request: PendingRequest)
}
