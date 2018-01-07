//
//  CollectionViewHeader.swift
//  photoGallery
//
//  Created by Arup Saha on 08/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit

class CollectionViewHeader: UICollectionReusableView {
    @IBOutlet fileprivate weak var label: PGLabel!
    
    var text: String = "" {
        didSet {
            label.text = text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
