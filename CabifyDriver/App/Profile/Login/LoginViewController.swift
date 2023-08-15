//
//  LoginViewController.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 27/07/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController {

    var delegate: LoginViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        modalPresentationStyle = .custom
        guard let sheet = sheetPresentationController else { return }
        sheet.detents = [.medium()]
    }
    
    // MARK: Sign In
    
    func signIn(with credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("ERROR")
                print(error)
            }
            guard error == nil else { return }
            guard let authResult = authResult else { return }
            
            self.dismiss(animated: true) {
                self.delegate?.userDidLogin(user: authResult.user)
            }
        }
    }
    
    // MARK: Google
    
    @IBAction func googleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            guard error == nil else {
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            self.signIn(with: credential)
        }
    }
}
