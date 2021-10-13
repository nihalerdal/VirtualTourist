//
//  PhotoResponse.swift
//  VirtualTourist
//
//  Created by Nihal Erdal on 10/12/21.
//

import Foundation

struct PhotoResponse: Codable {
    
    let photos: Photos
    let status: String
}

struct Photos : Codable {
    let page : String
    let pages: String
    let perPage: String
    let total: String
    let photo: [FlickerPhoto?]
}

struct FlickerPhoto: Codable {
    let id : String
    let owner: String
    let secret: String
    let server: String
    let title: String
    let ispublic: String
    let isfriend: String
    let isfamily: String
}
