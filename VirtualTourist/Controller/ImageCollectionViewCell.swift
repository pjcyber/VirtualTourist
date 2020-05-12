//
//  ImageCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Pjcyber on 5/3/20.
//  Copyright © 2020 Pjcyber. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    static let cellIdentifier = "ImageCell"
}
