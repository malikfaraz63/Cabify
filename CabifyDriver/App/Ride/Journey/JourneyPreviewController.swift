//
//  JourneyPreviewController.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 11/08/2023.
//

import UIKit
import MapKit

class JourneyPreviewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var previewStepsTable: UITableView!
    
    var previewSteps: [MKRoute.Step]?
    
    var delegate: JourneyPreviewDelegate?
    
    override func viewDidLoad() {
        print("--JourneyPreviewController.viewDidLoad()--")
        super.viewDidLoad()
        
        previewStepsTable.dataSource = self
        previewStepsTable.delegate = self
        
        modalPresentationStyle = .custom
        guard let sheet = sheetPresentationController else { return }
        sheet.detents = [.medium()]
        
        previewStepsTable.reloadData()
    }
    
    // MARK: Delegate
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let previewSteps = previewSteps else { return }
        let step = previewSteps[indexPath.section]
        delegate?.journeyPreviewDidSelectStep(step)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let steps = previewSteps else { return 0 }
        return steps.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let previewStepCell = tableView.dequeueReusableCell(withIdentifier: PreviewStepCell.identifier) as? PreviewStepCell else { fatalError() }
        guard let previewSteps = previewSteps else { return previewStepCell }
        let step = previewSteps[indexPath.section]
        
        previewStepCell.distanceLabel.text = "\(Int(step.distance)) m"
        previewStepCell.instructionsLabel.text = step.instructions
        
        return previewStepCell
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.journeyPreviewDidDismiss()
    }
}
