//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Pjcyber on 5/9/20.
//  Copyright © 2020 Pjcyber. All rights reserved.
//
//

import Foundation
import CoreData

extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var url: String?
    @NSManaged public var image: Data?
    @NSManaged public var pin: Pin?

}
