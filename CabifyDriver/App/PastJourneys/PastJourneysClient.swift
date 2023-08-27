//
//  PastJourneysClient.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 25/08/2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class PastJourneysClient {
    private let db = Firestore.firestore()
    
    typealias PastJourneysCompletion = ([PastJourney]) -> Void
    
    enum UserType: String {
        case drivers
        case riders
    }
    
    public func getPastJourneys(forUserId userId: String, type: UserType, completion: @escaping PastJourneysCompletion) {
        print("--PastJourneysClient.getPastJourneys")
        db
            .collection(type.rawValue).document(userId)
            .collection("completedRides")
            .getDocuments { querySnapshot, error in
                if let querySnapshot = querySnapshot {
                    print(" - document count: \(querySnapshot.count)")
                    var pastJourneys: [PastJourney]
                    do {
                        print("EE")
                        pastJourneys = try querySnapshot.documents.map { try $0.data(as: PastJourney.self) }
                        print("FF")
                        completion(pastJourneys)
                    } catch let error {
                        print(error)
                    }
                } else if let error = error {
                    print(error)
                }
            }
    }
}
