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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
