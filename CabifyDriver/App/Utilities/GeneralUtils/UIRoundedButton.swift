//
//  UIRoundedButton.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 04/08/2023.
//

import UIKit

class UIRoundedButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }

    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      didLoad()
    }

    convenience init() {
      self.init(frame: CGRectZero)
    }
    
    func didLoad() {
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
    }
}
