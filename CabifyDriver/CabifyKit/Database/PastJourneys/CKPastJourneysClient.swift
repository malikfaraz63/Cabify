//
//  CKPastJourneysClient.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 25/08/2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class CKPastJourneysClient {
    private let db = Firestore.firestore()
    
    typealias PastJourneysCompletion = ([PastJourney]) -> Void
    
    enum UserType: String {
        case drivers
        case riders
    }
    
    public func getPastJourneys(forUserId userId: String, type: UserType, completion: @escaping PastJourneysCompletion) {
        db
            .collection(type.rawValue).document(userId)
            .collection("completedRides")
            .getDocuments { querySnapshot, error in
                if let querySnapshot = querySnapshot {
                    var pastJourneys: [PastJourney]
                    do {
                        pastJourneys = try querySnapshot.documents.map { try $0.data(as: PastJourney.self) }
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
