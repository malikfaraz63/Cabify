
struct Coordinate {
    let latitude: Double
    let longitude: Double
}

let topLeftBound = Coordinate(latitude: 51.7, longitude: -0.6)
let bottomRightBound = Coordinate(latitude: 51.3, longitude: 0.30)

func getNeighbouringHashes(_ centreHash: String) -> [String] {
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
func getNeighbouringHash(base: [Character], baseO: [String], recursive: [Character], recursiveO: [String], hash: String) -> String {
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

func generateHashForCoordinate(_ coordinate: Coordinate) -> String {
    return getHash(coordinate: coordinate, topLeft: topLeftBound, bottomRight: bottomRightBound)
}

func getHash(coordinate: Coordinate, topLeft: Coordinate, bottomRight: Coordinate, depth: Int = 6) -> String {
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
        topLeft: Coordinate(latitude: topLeftLat, longitude: topLeftLong),
        bottomRight: Coordinate(latitude: bottomRightLat, longitude: bottomRightLong),
        depth: depth - 1
    )
}

let hash = generateHashForCoordinate(Coordinate(latitude: 51.57719, longitude: 0.07564)) // start
let destinatino = generateHashForCoordinate(Coordinate(latitude: 51.56194, longitude: 0.07036)) // end


