//
//  UIRoundedView.swift
//  CabifyRider
//
//  Created by Faraz Malik on 13/08/2023.
//

import UIKit

class UIRoundedView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }

    required init(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      didLoad()
    }

    convenience init() {
      self.init(frame: CGRectZero)
    }
    
    func didLoad() {
        layer.cornerRadius = 20
        clipsToBounds = true
    }
}
