//
//  ProfileViewController.swift
//  CabifyRider
//
//  Created by Faraz Malik on 28/08/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class ProfileViewController: UIViewController, SetupViewDelegate, LoginViewDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var ratingsView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var fundsAvailable: UILabel!
    @IBOutlet weak var timeActiveLabel: UILabel!
    
    @IBOutlet weak var signInView: UIView!
    
    let db = Firestore.firestore()
    let profileClient = CKProfileClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ratingsView.clipsToBounds = true
        ratingsView.layer.cornerRadius = 20
        
        if RiderSettingsManager.hasUser() {
            loadSavedUser()
        } else {
            signInView.isHidden = false
        }
    }
    
    func loadSavedUser() {
        let uid = RiderSettingsManager.getUserID()!
        
        db
            .collection("riders")
            .document(uid)
            .getDocument(as: CKRider.self) { result in
                switch result {
                case .success(let rider):
                    self.updateDisplay(withRider: rider)
                case .failure(let error):
                    print(error)
                    self.userDidSignOut()
                }
            }
    }
    
    // MARK: View
    
    func clearDisplay() {
        profileImageView.image = UIImage(systemName: "person.crop.circle.badge.questionmark")
        profileImageView.layer.cornerRadius = 0
        
        nameLabel.text = "--"
        ratingLabel.text = "--"
        fundsAvailable.text = "-- funds"
        timeActiveLabel.text = "-- days"
        emailLabel.text = "--@--.com"
    }
    
    func updateDisplay(withRider rider: CKRider) {
        signInView.isHidden = true
        
        if let urlString = rider.photoURL, let url = URL(string: urlString) {
            profileImageView.load(url: url) {
                self.profileImageView.clipsToBounds = true
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
            }
        }
        nameLabel.text = rider.name
        emailLabel.text = rider.email
        if rider.ratings.count > 0 {
            ratingLabel.text = String(format: "%.2f", rider.ratings.average)
        } else {
            ratingLabel.text = "N.A."
        }
        
        fundsAvailable.text = String(format: "£%.2f funds", rider.funds)
        
        let days = Int(Date().timeIntervalSince(rider.accountCreated)) / 86400
        if days < 365 {
            timeActiveLabel.text = "\(days) day" + (days != 1 ? "s" : "")
        } else {
            let years = days / 365
            timeActiveLabel.text = "\(years) year" + (years != 1 ? "s" : "")
        }
        
    }
    
    // MARK: Login
    
    func userDidLogin(user: User) {
        RiderSettingsManager.setUserID(to: user.uid)
        
        db
            .collection("riders")
            .document(user.uid)
            .getDocument(as: CKRider.self) { result in
                switch result {
                case .success(let rider):
                    self.updateDisplay(withRider: rider)
                case .failure(let error):
                    print(error)
                    self.setupNewRider(withUser: user)
                }
            }
    }
    
    // MARK: Setup
    
    func riderDidSetup(withRider rider: CKRider) {
        updateDisplay(withRider: rider)
        guard let uid = RiderSettingsManager.getUserID() else { return }
        
        var data: [String: Any] = [
            "riderId": rider.riderId,
            "name": rider.name,
            "email": rider.email,
            "phone": rider.phone,
            "accountCreated": rider.accountCreated,
            "funds": rider.funds,
            "ratings": [
                "average": rider.ratings.average,
                "count": rider.ratings.count
            ],
            "ridesCount": rider.ridesCount
        ]
        
        if let photoURL = rider.photoURL {
            data.updateValue(photoURL, forKey: "photoURL")
        }
        
        db
            .collection("riders")
            .document(uid)
            .setData(data) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
    }
    
    func setupNewRider(withUser user: User) {
        guard let setupController = storyboard?.instantiateViewController(identifier: StoryboardTag.setupViewController.rawValue) as? SetupViewController else { return }
        
        setupController.transitioningDelegate = self
        setupController.delegate = self
        setupController.user = user
        navigationController?.showDetailViewController(setupController, sender: nil)
    }
    
    
    @IBAction func userDidSignOut() {
        RiderSettingsManager.deleteUser()
        clearDisplay()
        signInView.isHidden = false
        
        do {
            try Auth.auth().signOut()
        } catch {
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueTag.showLogin.rawValue {
            guard let loginViewController = segue.destination as? LoginViewController else { return }
            
            loginViewController.delegate = self
            loginViewController.transitioningDelegate = self
        }
    }
}
