//
//  EarningsUIController.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 23/08/2023.
//

import SwiftUI
import UIKit

class EarningsUIController: UIHostingController<EarningsUIView> {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: EarningsUIView())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
