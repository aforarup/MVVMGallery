//
//  PhotoCollectionViewCell.swift
//  photoGallery
//
//  Created by Arup Saha on 04/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet fileprivate weak var imageView: UIImageView! {
        didSet {
            imageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            imageView.contentMode = .scaleAspectFill
        }
    }
    
    var image: UIImage? = nil {
        didSet {
            imageView.image = image
        }
    }
    
    var imageName: String? = nil {
        didSet {
            guard let imageName = imageName else {
                imageView.image = nil
                return
            }
            image = UIImage(named: imageName)
        }
    }
    
    var urlString: String? = nil {
        didSet {
            guard let urlString = urlString else {
                imageView.image = nil
                return
            }
            imageView.kf.setImage(with: URL(string: urlString))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
