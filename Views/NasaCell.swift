//
//  NasaCell.swift
//  Mars-Rovers
//
//  Created by Shiv Kalola on 9/18/19.
//  Copyright © 2019 Shiv Kalola. All rights reserved.
//

import Foundation
import UIKit

class NasaCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
     
    func updateImageView(with image: UIImage?) {
        self.imageView.image = image
    }
}

