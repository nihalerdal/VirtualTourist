//
//  FlickerClient.swift
//  VirtualTourist
//
//  Created by Nihal Erdal on 10/12/21.
//

import Foundation

class FlickerClient{
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        
        case getPhotos(Double, Double)
        case getUrls(String, String, String)
        
        struct Auth {
            static let apikey = "038fb6b77ba1f9d6dc1370974fa45c52"
        }
        
        var stringValue: String{
            
            
            switch self {
            case .getPhotos(let latitude, let longitude): return Endpoints.base + "&api_key=\(Auth.apikey)&lat=\(latitude)&lon=\(longitude)"
            case .getUrls(let serverId, let id, let secret): return "https://live.staticflickr.com/\(serverId)/\(id)_\(secret).jpg"
            }
        }
        
        var url: URL{
            return URL(string: stringValue)!
        }
    }
}
