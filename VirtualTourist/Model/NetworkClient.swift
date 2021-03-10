//
//  NetworkClient.swift
//  VirtualTourist
//
//  Created by Katharina Müllek on 25.02.21.
//

import Foundation
import UIKit

class NetworkClient {

    
    struct Auth {
        static let apiKey = "Please enter your API-Key"
        static let apiSecret = "Please enter your API-Secret"
    }
    
    struct LocationInput {
        static var latitude = 0.0
        static var longitude = 0.0
        static var page = Int.random(in: 1...25)
    }
    

    enum Endpoints {
        case getImageInfoForLocation(Double, Double)
        case fetchImageForLocation(String, String, String)
    
        var stringValue: String {
            switch self {
            case .getImageInfoForLocation(let latitude, let longitude):
                return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Auth.apiKey)&lat=\(latitude)&lon=\(longitude)&radius=5&per_page=10&page=\(LocationInput.page)&format=json&nojsoncallback=1"
            case .fetchImageForLocation(let serverId, let id, let secret):
                return "https://live.staticflickr.com/\(serverId)/\(id)_\(secret).jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func getImageInformation(latitude: Double, longitude: Double, completionHandler: @escaping (Images?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getImageInfoForLocation(latitude, longitude).url, responseType: NetworkResponse.self) { (response, error) in
            if let response = response {
                completionHandler(response.photos, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    

    class func getImage(image: Image, completion: @escaping (UIImage?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.fetchImageForLocation(image.server, image.id, image.secret).url) { (data, response, error) in
                guard let data = data else {
                    completion(nil, error)
                    return
            }
            let fetchedImage = UIImage(data: data)
            completion(fetchedImage, nil)
        }
        task.resume()
        
    }

    
}
