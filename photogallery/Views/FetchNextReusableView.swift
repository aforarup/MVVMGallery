//
//  FetchNextReusableView.swift
//  photoGallery
//
//  Created by Arup Saha on 06/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit

final class FetchNextReusableView: UICollectionReusableView {
    @IBOutlet fileprivate weak var label: PGLabel! {
        didSet {
            label.text = PGConstants.Strings.loading.localized
        }
    }
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
