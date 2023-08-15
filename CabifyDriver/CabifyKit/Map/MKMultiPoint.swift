//
//  MKMultiPoint.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 11/08/2023.
//

import UIKit
import MapKit

extension MKMultiPoint {
    /// The coordinates of the polyline.
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: pointCount)

        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))

        return coords
    }
}
