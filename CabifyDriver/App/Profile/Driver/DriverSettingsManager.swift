//
//  DriverSettingsManager.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 27/07/2023.
//

import Foundation

class DriverSettingsManager {
    static let defaults = UserDefaults.standard
    
    static private let key = "documentID"
    
    static func hasUser() -> Bool {
        return getUserID() != nil
    }
    
    static func getUserID() -> String? {
        return defaults.string(forKey: key)
    }
    
    static func deleteUser() {
        defaults.removeObject(forKey: key)
    }
    
    static func setUserID(to uid: String) {
        defaults.setValue(uid, forKey: key)
    }
}
