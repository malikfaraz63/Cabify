//
//  SetupViewController.swift
//  CabifyRider
//
//  Created by Faraz Malik on 28/08/2023.
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
        let url = user.photoURL?.absoluteString
        let uid = user.uid
        
        delegate?.riderDidSetup(withRider: CKRider(riderId: uid, name: name, email: email, photoURL: url, phone: "07368199935", funds: 100, ridesCount: 0, ratings: CKRatingSummary(average: 0, count: 0), accountCreated: Date()))
        
        dismiss(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
