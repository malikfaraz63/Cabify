//
//  RatingViewController.swift
//  CabifyRider
//
//  Created by Faraz Malik on 28/08/2023.
//

import UIKit

class RatingViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var commentsView: UITextView!
    @IBOutlet weak var ratingStackView: UIStackView!
    
    @IBOutlet weak var submitRatingButton: UIButton!
    
    let ratingClient = CKRatingClient()
    var driver: CKDriver?
    var rideId: String?
    
    var selectedRating: Int?
    weak var lastSelectedButton: UIButton?
    
    var delegate: RatingViewDelegate?
    
    override func viewDidLoad() {
        guard let driver = driver else { return }
        titleLabel.text = "Rate \(driver.name)"
        
        commentsView.delegate = self
        super.viewDidLoad()

        guard let ratingButtons = ratingStackView.subviews as? [UIButton] else { return }
        
        for i in 0..<ratingButtons.count {
            ratingButtons[i].addAction(UIAction { [unowned self] _ in
                submitRatingButton.isEnabled = true
                ratingButtons[0..<ratingButtons.count].forEach {
                    $0.tintColor = .label
                }
                
                if let lastSelectedButton = lastSelectedButton {
                    if lastSelectedButton == ratingButtons[i] {
                        ratingButtons[0..<ratingButtons.count].forEach {
                            $0.setImage(UIImage(systemName: "star"), for: .normal)
                        }
                        selectedRating = 0
                        return
                    }
                }
                
                ratingButtons[i+1..<ratingButtons.count].forEach {
                    $0.setImage(UIImage(systemName: "star"), for: .normal)
                }
                ratingButtons[0...i].forEach {
                    $0.setImage(UIImage(systemName: "star.fill"), for: .normal)
                }
                
                selectedRating = i + 1
                lastSelectedButton = ratingButtons[i]
            }, for: .touchUpInside)
        }
    }
    
    @IBAction func submitRating() {
        guard let driver = driver else { return }
        guard let rideId = rideId else { return }
        
        let comments: String?
        if commentsView.text.isEmpty {
            comments = nil
        } else {
            comments = commentsView.text
        }
        
        let rating = CKRating(
            stars: selectedRating!,
            comments: comments
        )
        
        
        ratingClient.setRating(forUserId: driver.driverId, userType: .drivers, rideId: rideId, rating: rating) {
            self.delegate?.didSetRating(rating)
            self.dismiss(animated: true)
        }
    }
    
    // MARK: Text View Delegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentsView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
