//
//  PlacesClient.swift
//  CabifyRider
//
//  Created by Faraz Malik on 13/08/2023.
//

import Foundation

class PlacesClient {
    private static let baseUrl = "https://maps.googleapis.com/maps/api"
    private static let apiKey = "AIzaSyCzirLfaVSznz7N8b0R8na2cJCx8LwIkeI"
    typealias AutocompletePredictionsCompletion = ([LocationPrediction]) -> Void
    typealias LocationDetailCompletion = (CKCoordinate) -> Void
    typealias DescriptionDetailCompletion = (LocationDescription) -> Void
    
    public static func getAutocompletePredictions(forInput input: String, location: CKCoordinate, radius: Int = 50000, completion: @escaping AutocompletePredictionsCompletion) {
        let autocompleteBaseUrl = baseUrl + "/place/autocomplete/json?"
        let parameters = "input=\(input.replacingOccurrences(of: " ", with: "%20"))&location=\(location.latitude)%2C\(location.longitude)&radius=\(radius)&fields=place_id&key=\(apiKey)"
        
        let urlString = autocompleteBaseUrl + parameters
        
        sendRequest(withUrlString: urlString) { data in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let wrapper = try decoder.decode(PredictionsWrapper.self, from: data)
                completion(wrapper.predictions)
            } catch let otherError {
                print(otherError)
            }
        }
    }
    
    public static func getLocationDetail(forPlaceId placeId: String, completion: @escaping LocationDetailCompletion) {
        let detailBaseUrl = baseUrl + "/place/details/json?"
        let parameters = "place_id=\(placeId)&fields=geometry&key=\(apiKey)"
        
        let urlString = detailBaseUrl + parameters
        
        sendRequest(withUrlString: urlString) { data in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let wrapper = try decoder.decode(DetailWrapper.self, from: data)
                completion(wrapper.result.geometry.location)
            } catch let otherError {
                print(otherError)
            }
        }
    }
    
    public static func getDescription(forCoordinate coordinate: CKCoordinate, completion: @escaping DescriptionDetailCompletion) {
        let descriptionBaseUrl = baseUrl + "/geocode/json?"
        let parameters = "latlng=\(coordinate.latitude)%2C\(coordinate.longitude)&key=\(apiKey)"
        
        let urlString = descriptionBaseUrl + parameters
        
        sendRequest(withUrlString: urlString) { data in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let wrapper = try decoder.decode(DescriptionWrapper.self, from: data)
                if wrapper.results.isEmpty {
                    print("no results found")
                } else {
                    completion(wrapper.results.first!)
                }
            } catch let otherError {
                print(otherError)
            }
        }
    }
    
    private static func sendRequest(withUrlString urlString: String, completion: @escaping (Data) -> Void) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        
        let task = URLSession(configuration: .default).dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    completion(data)
                } else if let error = error {
                    print(error)
                }
            }
        }
        task.resume()
    }
}
