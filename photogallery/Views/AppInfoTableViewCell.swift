//
//  AppInfoTableViewCell.swift
//  photoGallery
//
//  Created by Arup Saha on 11/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit

class AppInfoTableViewCell: PGTableViewCell {
    @IBOutlet fileprivate weak var titleLabel: PGLabel!
    @IBOutlet fileprivate weak var descriptionLabel: PGLabel!
    
    var titleText: String = "" {
        didSet {
            titleLabel.text = titleText
        }
    }
    
    var descriptionText: String = "" {
        didSet {
            descriptionLabel.text = descriptionText
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
