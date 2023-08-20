//
//  UIImageView.swift
//  CabifyRider
//
//  Created by Faraz Malik on 18/08/2023.
//

import Foundation
import UIKit

extension UIImageView {
    typealias ImageLoadCompletion = () -> Void
    
    func load(url: URL, completion: ImageLoadCompletion? = nil) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        completion?()
                    }
                }
            }
        }
    }
}
