//
//  RouteSelectionDelegate.swift
//  CabifyRider
//
//  Created by Faraz Malik on 13/08/2023.
//

import Foundation

enum SelectionType {
    case pickup
    case dropoff
}

protocol RouteSelectionDelegate {
    func showRouteSelectionTable()
    func hideRouteSelectionTable()
    func didSelectLocation(ofType type: SelectionType, location: CKCoordinate)
    func beginPinSelection(forType type: SelectionType)
}
