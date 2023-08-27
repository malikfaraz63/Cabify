//
//  CKProfileClient.swift
//  CabifyRider
//
//  Created by Faraz Malik on 25/08/2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class CKProfileClient {
    private let db = Firestore.firestore()
    
    typealias RiderCompletion = (CKRider) -> Void
    typealias DriverCompletion = (CKDriver) -> Void
    
    public func getDriver(withDriverId driverId: String, completion: @escaping DriverCompletion) {
        db
            .collection("drivers")
            .document(driverId)
            .getDocument(as: CKDriver.self) { result in
                switch result {
                case .success(let driver):
                    completion(driver)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    public func getRider(withRiderId riderId: String, completion: @escaping RiderCompletion) {
        db
            .collection("riders")
            .document(riderId)
            .getDocument(as: CKRider.self) { result in
                switch result {
                case .success(let rider):
                    completion(rider)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    typealias SessionFetchCompletion = (CKRequestFetch?, CKRideFetch?) -> Void
    public func tryFetchSession(forRiderId riderId: String, completion: @escaping SessionFetchCompletion) {
        db
            .collection("requests")
            .whereField("riderId", isEqualTo: riderId)
            .whereFilter(Filter.orFilter([
                Filter.whereField("status", isEqualTo: CKRequestStatus.pending.rawValue),
                Filter.whereField("status", isEqualTo: CKRequestStatus.active.rawValue)
            ]))
            .getDocuments(source: .server) { querySnapshot, error in
                if let querySnapshot = querySnapshot {
                    if querySnapshot.isEmpty {
                        self.tryRideFetch(forRiderId: riderId, completion: completion)
                        return
                    }
                    
                    let document = querySnapshot.documents.first!
                    do {
                        print(document.data())
                        let requestFetch = try document.data(as: CKRequestFetch.self)
                        completion(requestFetch, nil)
                    } catch let error {
                        print(error)
                    }
                } else if let error = error {
                    print(error)
                }
            }
    }
    
    private func tryRideFetch(forRiderId riderId: String, completion: @escaping SessionFetchCompletion) {
        db
            .collection("rides")
            .whereField("riderId", isEqualTo: riderId)
            .whereFilter(Filter.orFilter([
                Filter.whereField("status", isEqualTo: CKRideStatus.waiting.rawValue),
                Filter.whereField("status", isEqualTo: CKRideStatus.active.rawValue)
            ]))
            .getDocuments(source: .server) { querySnapshot, error in
                if let querySnapshot = querySnapshot {
                    if querySnapshot.isEmpty {
                        completion(nil, nil)
                        return
                    }
                    
                    let document = querySnapshot.documents.first!
                    do {
                        let rideFetch = try document.data(as: CKRideFetch.self)
                        completion(nil, rideFetch)
                    } catch let error {
                        print(error)
                    }
                } else if let error = error {
                    print(error)
                }
            }
    }
}
