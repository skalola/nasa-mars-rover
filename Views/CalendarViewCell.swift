//
//  CalendarViewCell.swift
//  Mars-Rovers
//
//  Created by Shiv Kalola on 9/17/19.
//  Copyright © 2019 Shiv Kalola. All rights reserved.
//

import Foundation
import UIKit

class CalendarViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateImage: UIImageView!
    
    override func layoutSubviews() {
        dateImage.layer.cornerRadius = dateImage.bounds.height / 2
        dateImage.clipsToBounds = true
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                dateLabel!.textColor = UIColor.green
                dateLabel.font = UIFont.boldSystemFont(ofSize: 14)
                dateImage.layer.borderWidth = 4
                dateImage.layer.borderColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
            } else {
                dateLabel!.textColor = UIColor.darkText
                dateLabel.font = UIFont.systemFont(ofSize: 14)
                dateImage.layer.borderWidth = 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
