//
//  ProfileViewController.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 24/07/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class ProfileViewController: UIViewController, LoginViewDelegate, SetupViewDelegate,  UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var ratingsView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var tripsCountLabel: UILabel!
    @IBOutlet weak var yearsLabel: UILabel!
    
    @IBOutlet weak var signInView: UIView!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ratingsView.clipsToBounds = true
        ratingsView.layer.cornerRadius = 20
        
        if DriverSettingsManager.hasUser() {
            loadSavedUser()
        } else {
            signInView.isHidden = false
        }
    }
    
    func loadSavedUser() {
        let uid = DriverSettingsManager.getUserID()!
        
        db
            .collection("drivers")
            .document(uid)
            .getDocument(as: Driver.self) { result in
                switch result {
                case .success(let driver):
                    self.updateDisplay(withDriver: driver)
                case .failure:
                    self.userDidSignOut()
                }
            }
    }
    
    // MARK: Login
    
    func userDidLogin(user: User) {
        DriverSettingsManager.setUserID(to: user.uid)
        
        db
            .collection("drivers")
            .document(user.uid)
            .getDocument(as: Driver.self) { result in
                switch result {
                case .success(let driver):
                    self.updateDisplay(withDriver: driver)
                case .failure:
                    self.setupNewDriver(withUser: user)
                }
            }
    }
    
    // MARK: Setup
    
    func driverDidSetup(withDriver driver: Driver) {
        updateDisplay(withDriver: driver)
        guard let uid = DriverSettingsManager.getUserID() else { return }
        
        var data: [String: Any] = [
            "name": driver.name,
            "email": driver.email,
            "phone": driver.phone,
            "accountCreated": driver.accountCreated,
            "earnings": driver.earnings,
            "averageRating": driver.averageRating,
            "ridesCount": driver.ridesCount
        ]
        
        if let photoURL = driver.photoURL {
            data.updateValue(photoURL, forKey: "photoURL")
        }
        
        db
            .collection("drivers")
            .document(uid)
            .setData(data) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
    }
    
    func setupNewDriver(withUser user: User) {
        guard let setupController = storyboard?.instantiateViewController(identifier: StoryboardTag.setupViewController.rawValue) as? SetupViewController else { return }
        
        setupController.transitioningDelegate = self
        setupController.delegate = self
        setupController.user = user
        navigationController?.showDetailViewController(setupController, sender: nil)
    }
        
    func clearDisplay() {
        profileImageView.image = UIImage(systemName: "person.crop.circle.badge.questionmark")
        profileImageView.layer.cornerRadius = 0
        
        nameLabel.text = "--"
        ratingLabel.text = "--"
        tripsCountLabel.text = "-- trips"
        yearsLabel.text = "-- years"
        emailLabel.text = "--@--.com"
    }
    
    func updateDisplay(withDriver driver: Driver) {
        signInView.isHidden = true
        
        if let urlString = driver.photoURL, let url = URL(string: urlString) {
            profileImageView.load(url: url) {
                self.profileImageView.clipsToBounds = true
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
            }
        }
        nameLabel.text = driver.name
        emailLabel.text = driver.email
        if driver.ridesCount > 0 {
            ratingLabel.text = String(format: "%.2f", driver.averageRating)
        } else {
            ratingLabel.text = "N.A."
        }
        
        tripsCountLabel.text = "\(driver.ridesCount) trip" + (driver.ridesCount != 1 ? "s" : "")
        let years = Int( Date().timeIntervalSince(driver.accountCreated)) / (86400 * 365)
        yearsLabel.text = "\(years) year" + (years != 1 ? "s" : "")
    }
    
    @IBAction func userDidSignOut() {
        DriverSettingsManager.deleteUser()
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
