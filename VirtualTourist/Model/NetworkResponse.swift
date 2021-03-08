//
//  NetworkResponse.swift
//  VirtualTourist
//
//  Created by Katharina Müllek on 01.03.21.
//

import Foundation
import UIKit

struct NetworkResponse: Codable {
    let photos: Images
}

struct Images: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Image]
}

struct Image: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}

