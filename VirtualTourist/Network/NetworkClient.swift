//
//  NetworkClient.swift
//  Virtual Tourist
//
//  Created by Maha on 27/11/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct NetworkClient {
    
    typealias PhotoRequest = ([PhotoUrl]?, Error?) -> Void
    
    static func requestURLPhotos(latitude: Double, longitude: Double, page: Int, complition: @escaping PhotoRequest) {
        
        let url = constructURLForSearchPhotot(minLatitude: latitude, minLongitude: longitude, page: page)
        
        Alamofire.request(url).validate().responseData { (response) in
            
            switch response.result {
            case .success:
                if let data = response.result.value {
                    if let photos = convertDataToJsonObject(objectType: Photos.self, data: data) {
                        complition(photos.photos.photo, nil)
                    }
                }
                
            case .failure(let error):
                complition(nil, error)
            }
        }
    }
    
    static func convertDataToJsonObject<structName: Codable>(objectType: structName.Type, data: Data) -> structName? {
        do {
            return try JSONDecoder().decode(objectType, from: data)
        }catch {
            return nil
        }
    }
    
    static func constructURLForSearchPhotot(minLatitude: Double, minLongitude: Double, page: Int) -> URL{
        
        // URL Components
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = [URLQueryItem]()
        
        let maxLatitude = Double(minLatitude) + 1.0
        let maxLongitude = Double(minLongitude) + 1.0
        let bbox: String = "\(minLongitude),\(minLatitude),\(maxLongitude),\(maxLatitude)"
        
        components.queryItems?.append(URLQueryItem(name: "method", value: "flickr.photos.search"))
        components.queryItems?.append(URLQueryItem(name: "api_key", value: "952420950091fae8e2870d2f6dd3059e"))
        components.queryItems?.append(URLQueryItem(name: "bbox", value: bbox))
        components.queryItems?.append(URLQueryItem(name: "extras", value: "url_m"))
        components.queryItems?.append(URLQueryItem(name: "per_page", value: "12"))
        components.queryItems?.append(URLQueryItem(name: "page", value: "\(page)"))
        components.queryItems?.append(URLQueryItem(name: "format", value: "json"))
        components.queryItems?.append(URLQueryItem(name: "nojsoncallback", value: "1"))
        
        return components.url!
    }
    
}

