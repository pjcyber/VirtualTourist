//
//  Picture.swift
//  VirtualTourist
//
//  Created by Pjcyber on 4/30/20.
//  Copyright © 2020 Pjcyber. All rights reserved.
//

import Foundation

struct PhotoResponse: Codable {
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
