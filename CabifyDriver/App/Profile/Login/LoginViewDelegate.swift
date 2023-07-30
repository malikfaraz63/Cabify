//
//  LoginViewDelegate.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 27/07/2023.
//

import Foundation
import FirebaseAuth

protocol LoginViewDelegate {
    func userDidLogin(user: User)
}
