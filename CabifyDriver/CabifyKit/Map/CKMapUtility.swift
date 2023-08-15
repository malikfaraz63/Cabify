//
//  MapUtility.swift
//  CabifyDriver
//
//  Created by Faraz Malik on 25/07/2023.
//

import Foundation
import CoreLocation

public class CKMapUtility {
    static let topLeftBound = CLLocationCoordinate2D(latitude: 51.7, longitude: -0.6)
    static let bottomRightBound = CLLocationCoordinate2D(latitude: 51.3, longitude: 0.30)
    
    static func getDistanceBetweenCoordinates(_ a: CKCoordinate, _ b: CKCoordinate) -> CLLocationDistance {
        return getDegreesBetweenCoordinates(a, b) * 111195
    }
    
    static func getDegreesBetweenCoordinates(_ a: CKCoordinate, _ b: CKCoordinate) -> CLLocationDegrees {
        let dLat = a.latitude - b.latitude
        let dLong = a.longitude - b.longitude
        
        return sqrt(dLat * dLat + dLong * dLong)
    }
    
    static func generateHashForCoordinate(_ coordinate: CKCoordinate) -> String {
        return getHash(coordinate: coordinate, topLeft: self.topLeftBound, bottomRight: self.bottomRightBound)
    }
    
    static func getNeighbouringHashes(_ centreHash: String) -> [String] {
        let caseBelow = getNeighbouringHash(base: ["0", "1"], baseO: ["2", "3"], recursive: ["2", "3"], recursiveO: ["0", "1"], hash: centreHash)
        let caseAbove = getNeighbouringHash(base: ["2", "3"], baseO: ["0", "1"], recursive: ["0", "1"], recursiveO: ["2", "3"], hash: centreHash)
        
        let caseLeft  = getNeighbouringHash(base: ["0", "2"], baseO: ["1", "3"], recursive: ["1", "3"], recursiveO: ["0", "2"], hash: centreHash)
        let caseTopLeft = getNeighbouringHash(base: ["2", "3"], baseO: ["0", "1"], recursive: ["0", "1"], recursiveO: ["2", "3"], hash: caseLeft)
        let caseBottomLeft = getNeighbouringHash(base: ["0", "1"], baseO: ["2", "3"], recursive: ["2", "3"], recursiveO: ["0", "1"], hash: caseLeft)
        
        let caseRight = getNeighbouringHash(base: ["1", "3"], baseO: ["0", "2"], recursive: ["0", "2"], recursiveO: ["1", "3"], hash: centreHash)
        let caseTopRight = getNeighbouringHash(base: ["2", "3"], baseO: ["0", "1"], recursive: ["0", "1"], recursiveO: ["2", "3"], hash: caseRight)
        let caseBottomRight = getNeighbouringHash(base: ["0", "1"], baseO: ["2", "3"], recursive: ["2", "3"], recursiveO: ["0", "1"], hash: caseRight)
        
        return [centreHash, caseLeft, caseRight, caseAbove, caseBelow, caseBottomLeft, caseBottomRight, caseTopLeft, caseTopRight]
    }
    
    // ~1.5ms runtime
    private static func getNeighbouringHash(base: [Character], baseO: [String], recursive: [Character], recursiveO: [String], hash: String) -> String {
        func nestedGetHash(hash: String) -> String {
            if hash == "" {
                return ""
            }
            
            let subCount = hash.count - 1
            let remainingString = String(hash.prefix(subCount))
            if hash.last! == base[0] {
                return remainingString + baseO[0]
            } else if hash.last! == base[1] {
                return remainingString + baseO[1]
            }
            
            if hash.last! == recursive[0] {
                return nestedGetHash(hash: remainingString) + recursiveO[0]
            } else if hash.last! == recursive[1] {
                return nestedGetHash(hash: remainingString) + recursiveO[1]
            }
            
            fatalError()
        }
        
        return nestedGetHash(hash: hash)
    }
    
    private static func getHash(coordinate: CKCoordinate, topLeft: CKCoordinate, bottomRight: CKCoordinate, depth: Int = 6) -> String {
        if depth == 0 {
            return ""
        }
        
        let midLat = (topLeft.latitude + bottomRight.latitude) / 2
        let midLong = (topLeft.longitude + bottomRight.longitude) / 2

        var topLeftLat = topLeft.latitude
        var topLeftLong = topLeft.longitude
        
        var bottomRightLat = bottomRight.latitude
        var bottomRightLong = bottomRight.longitude
        
        var index = 0
        if coordinate.latitude < midLat {
            index += 2
            topLeftLat = midLat
        } else {
            bottomRightLat = midLat
        }
        if coordinate.longitude > midLong {
            index += 1
            topLeftLong = midLong
        } else {
            bottomRightLong = midLong
        }
        
        return String(index) + getHash(
            coordinate: coordinate,
            topLeft: CLLocationCoordinate2D(latitude: topLeftLat, longitude: topLeftLong),
            bottomRight: CLLocationCoordinate2D(latitude: bottomRightLat, longitude: bottomRightLong),
            depth: depth - 1
        )
    }
}
