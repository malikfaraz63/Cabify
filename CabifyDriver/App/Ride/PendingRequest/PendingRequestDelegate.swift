//
//  PendingRequestDelegate.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 26/07/2023.
//

import Foundation

protocol PendingRequestDelegate {
    typealias PendingRequestHiddenCompletion = () -> Void

    func didTryToAcceptRequest(_ request: PendingRequest, completion: @escaping PendingRequestHiddenCompletion)
    func requestTimedOut(_ request: PendingRequest, completion: @escaping PendingRequestHiddenCompletion)
}
