//
//  RouteSelectionController.swift
//  CabifyRider
//
//  Created by Faraz Malik on 13/08/2023.
//

import UIKit
import CoreLocation

class RouteSelectionController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var pickupTextField: UITextField!
    @IBOutlet weak var dropoffTextField: UITextField!
    var lastSelectedTextField: UITextField?
    
    @IBOutlet weak var locationPredictionTable: UITableView!
    var locationPredictions: [CKLocationPrediction] = []
    var delegate: RouteSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addLeftPadding(toTextField: pickupTextField, padding: 5)
        addLeftPadding(toTextField: dropoffTextField, padding: 5)
        
        locationPredictionTable.dataSource = self
        locationPredictionTable.delegate = self
        
        pickupTextField.delegate = self
        dropoffTextField.delegate = self
        // Do any additional setup after loading the view.
    }
        
    func addLeftPadding(toTextField textField: UITextField, padding: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: pickupTextField.frame.height))
        
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    // MARK: Text Field Delegate
    
    @IBAction func pickupEditingDidBegin() {
        lastSelectedTextField = pickupTextField
        delegate?.showRouteSelectionTable()
        pickupTextChanged()
    }
    @IBAction func pickupTextChanged() {
        let pickupText = pickupTextField.text ?? ""
        reloadLocationPredictions(forInput: pickupText)
    }
    
    @IBAction func dropoffEditingDidBegin() {
        lastSelectedTextField = dropoffTextField
        delegate?.showRouteSelectionTable()
        dropoffTextChanged()
    }
    @IBAction func dropoffTextChanged() {
        let dropoffText = dropoffTextField.text ?? ""
        reloadLocationPredictions(forInput: dropoffText)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Route Selection
    
    func pinDidSelectLocation(withDescription description: String, type: SelectionType) {
        if type == .pickup {
            pickupTextField.text = String(description.split(separator: ",").first!)
            lastSelectedTextField = pickupTextField
            pickupTextChanged()
        } else {
            dropoffTextField.text = String(description.split(separator: ",").first!)
            lastSelectedTextField = dropoffTextField
            dropoffTextChanged()
        }
    }
    
    func reloadLocationPredictions(forInput input: String) {
        if input.isEmpty {
            self.locationPredictions = []
            locationPredictionTable.reloadData()
            return
        }
        
        CKPlacesClient.getAutocompletePredictions(forInput: input, location: CLLocationCoordinate2D(latitude: 51.57916, longitude: 0.07268)) { locationPredictions in
            self.locationPredictions = locationPredictions
            self.locationPredictionTable.reloadData()
        }
    }
    
    // MARK: Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == locationPredictions.count {
            let selectionType: SelectionType
            if lastSelectedTextField == pickupTextField {
                selectionType = .pickup
                let _ = textFieldShouldReturn(pickupTextField)
            } else if lastSelectedTextField == dropoffTextField {
                selectionType = .dropoff
                let _ = textFieldShouldReturn(dropoffTextField)
            } else {
                return
            }
            delegate?.beginPinSelection(forType: selectionType)
            return
        }
        
        let placeId = locationPredictions[indexPath.row].placeId

        CKPlacesClient.getLocationDetail(forPlaceId: placeId) { [unowned self] locationDetail in
            if lastSelectedTextField == pickupTextField {
                pickupTextField.text = locationPredictions[indexPath.row].structuredFormatting.mainText
                let _ = textFieldShouldReturn(pickupTextField)
                delegate?.didSelectLocation(ofType: .pickup, location: locationDetail)
            } else if lastSelectedTextField == dropoffTextField {
                dropoffTextField.text = locationPredictions[indexPath.row].structuredFormatting.mainText
                let _ = textFieldShouldReturn(dropoffTextField)
                delegate?.didSelectLocation(ofType: .dropoff, location: locationDetail)
            }
            delegate?.hideRouteSelectionTable()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    // MARK: Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationPredictions.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let routeSelectionCell = tableView.dequeueReusableCell(withIdentifier: RouteSelectionCell.identifier) as? RouteSelectionCell else { fatalError() }
        
        if indexPath.row < locationPredictions.count {
            routeSelectionCell.primaryLocationLabel.text = locationPredictions[indexPath.row].structuredFormatting.mainText
            routeSelectionCell.secondaryLocationLabel.text = locationPredictions[indexPath.row].structuredFormatting.secondaryText
            routeSelectionCell.locationTypeImage.image = UIImage(systemName: "mappin.circle.fill")
        } else {
            routeSelectionCell.primaryLocationLabel.text = "Set location on map"
            routeSelectionCell.secondaryLocationLabel.text = ""
            routeSelectionCell.locationTypeImage.image = UIImage(systemName: "location.circle.fill")
        }
        
        return routeSelectionCell
    }
}
