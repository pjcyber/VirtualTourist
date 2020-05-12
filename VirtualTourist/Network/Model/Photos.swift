//
//  Album.swift
//  VirtualTourist
//
//  Created by Pjcyber on 4/30/20.
//  Copyright © 2020 Pjcyber. All rights reserved.
//

import Foundation

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [PhotoResponse]
}
