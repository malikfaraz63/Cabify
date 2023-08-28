//
//  CKRatingClient.swift
//  CabifyRider
//
//  Created by Faraz Malik on 28/08/2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class CKRatingClient {
    private let db = Firestore.firestore()
    
    typealias RatingSetCompletion = () -> Void
    typealias RatingCompletion = (CKRating?) -> Void
    
    enum UserType: String {
        case riders
        case drivers
    }
    
    // how others rated him, is what is stored in riders/${riderId}/ratings
    public func getRating(forUserId userId: String, userType: UserType, rideId: String, completion: @escaping RatingCompletion) {
        db
            .collection(userType.rawValue).document(userId)
            .collection("ratings").document(rideId)
            .getDocument { documentSnapshot, error in
                if let documentSnapshot = documentSnapshot {
                    if documentSnapshot.exists {
                        do {
                            try completion(documentSnapshot.data(as: CKRating.self))
                        } catch let error {
                            print(error)
                        }
                    } else { completion(nil); return }
                } else if let error = error {
                    print(error)
                }
            }
    }
    
    public func setRating(forUserId userId: String, userType: UserType, rideId: String, rating: CKRating, completion: @escaping RatingSetCompletion) {
        let userRef = db.collection(userType.rawValue).document(userId)
        let ratingsRef = userRef.collection("ratings").document(rideId)
        
        db.runTransaction({ transaction, errorPointer -> Any? in
            let oldRatings: CKRatingSummary
            do {
                oldRatings = try transaction.getDocument(userRef).data(as: CKRatingsWrapper.self).ratings
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let newAverage = (oldRatings.average * Double(oldRatings.count) + Double(rating.stars)) / Double(oldRatings.count + 1)
            let newRatings: [String: Any] = [
                "average": newAverage,
                "count": oldRatings.count + 1
            ]
            
            do {
                try transaction.setData(from: rating, forDocument: ratingsRef)
            } catch let setError as NSError {
                errorPointer?.pointee = setError
                return nil
            }
            transaction.updateData(["ratings": newRatings], forDocument: userRef)
            
            return nil
        }) { object, error in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction committed!")
                completion()
            }
        }
    }

    private func getError(withTitle title: String, message: String) -> NSError {
        return NSError(
            domain: "AppErrorDomain",
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: "\(title): \(message)"
            ]
        )
    }
}
