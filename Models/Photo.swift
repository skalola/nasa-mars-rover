//
//  Photo.swift
//  Mars-Rovers
//
//  Created by Shiv Kalola on 9/17/19.
//  Copyright © 2019 Shiv Kalola. All rights reserved.
//

import Foundation

class Photo {
    let img_src: URL
    let photoID: String
    let earth_date: String
    
    init(img_src: URL, photoID: String, earth_date: String) {
        self.img_src = img_src
        self.photoID = photoID
        self.earth_date = earth_date
    }
}
