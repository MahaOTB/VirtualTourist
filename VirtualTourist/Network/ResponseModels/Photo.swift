//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Maha on 27/11/2018.
//  Copyright © 2018 Maha_AlOtaibi. All rights reserved.
//

import Foundation

struct Photos: Codable {
    let photos: photo
}

struct photo: Codable {
    let  photo: [PhotoUrl]
}

struct PhotoUrl: Codable {
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_m"
    }
}
