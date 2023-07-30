//
//  SetupViewController.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 27/07/2023.
//

import UIKit
import FirebaseAuth

class SetupViewController: UIViewController {
    
    var delegate: SetupViewDelegate?
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationStyle = .custom
        guard let sheet = sheetPresentationController else { return }
        sheet.detents = [.medium()]
    }
    
    @IBAction func createAccount() {
        guard let user = user else { return }
        guard let name = user.displayName else { return }
        guard let email = user.email else { return }
        guard let url = user.photoURL?.absoluteString else { return }
        
        
        
        delegate?.driverDidSetup(withDriver: Driver(name: name, email: email, isOnline: false, photoURL: url, phone: "07368989855", accountCreated: Date(), earnings: 0, averageRating: 0, tripsCount: 0))
        
        dismiss(animated: true)
    }
}
