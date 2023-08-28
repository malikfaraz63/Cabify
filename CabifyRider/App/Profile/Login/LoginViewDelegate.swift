//
//  LoginViewDelegate.swift
//  CabifyRider
//
//  Created by Faraz Malik on 28/08/2023.
//

import Foundation
import FirebaseAuth

protocol LoginViewDelegate {
    func userDidLogin(user: User)
}
