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
    
    enum CodingKeys: String, CodingKey{
        case photos = "photos"
        case status = "stat"
    }
}

struct Photos : Codable {
    let page : Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [FlickerPhoto]
}

struct FlickerPhoto: Codable {
    let id : String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
