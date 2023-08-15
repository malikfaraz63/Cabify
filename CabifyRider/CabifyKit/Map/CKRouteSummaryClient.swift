//
//  CKRouteSummaryClient.swift
//  CabifyKit
//
//  Created by Faraz Malik on 12/08/2023.
//

import Foundation

public enum DistanceUnit: String {
    case imperial
    case metric
}

public typealias RouteSummaryCompletion = (CKRouteSummary) -> Void

public class CKRouteSummaryClient {
    private static let baseUrl = "https://maps.googleapis.com/maps/api/distancematrix/json?"
    private static let apiKey = "AIzaSyCzirLfaVSznz7N8b0R8na2cJCx8LwIkeI"
    
    public static func getRouteSummary(fromOrigin origin: CKCoordinate, destination: CKCoordinate, units: DistanceUnit, completion: @escaping RouteSummaryCompletion) {
        let parameters = "origins=\(origin.latitude)%2C\(origin.longitude)&destinations=\(destination.latitude)%2C\(destination.longitude)&units=\(units.rawValue)&key=\(apiKey)"
        
        let urlString = baseUrl + parameters
        
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        
        let task = URLSession(configuration: .default).dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let wrapper = try decoder.decode(CKRouteSummaryWrapper.self, from: data)
                        completion(CKRouteSummary(originAddress: wrapper.originAddresses[0], destinationAddress: wrapper.destinationAddresses[0], distance: wrapper.rows[0].elements[0].distance, duration: wrapper.rows[0].elements[0].duration))
                    } catch let otherError {
                        print(otherError)
                    }
                } else if let error = error {
                    print(error)
                }
            }
            
        }
        
        task.resume()
    }
}
