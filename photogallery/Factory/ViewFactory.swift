//
//  ViewFactory.swift
//  photoGallery
//
//  Created by Arup Saha on 04/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit

class ViewFactory {
    class func getPhotoSourceAlertController(_ sources: [PhotoSource], delegate: PhotoSourceDelegate) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sources.forEach({ (source) -> Void in
            let action = UIAlertAction(title: source.rawValue.localized, style: .default, handler: { (action) in
                delegate.didSelectPhotoSouce(source)
            })
            alertController.addAction(action)
        })
        alertController.addAction(UIAlertAction(title: PGConstants.Strings.cancel.localized, style: .cancel, handler: nil))
        return alertController
    }
    
    class func getShareTargetAlertController(_ shareTargets: [ShareTargetProtocol], delegate: PhotoShareTargetDelegate) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        shareTargets.forEach({ (shareTarget) -> Void in
            let action = UIAlertAction(title: shareTarget.target.rawValue.localized, style: .default, handler: { (action) in
                delegate.didSelectPhotoShareTarget(shareTarget)
            })
            alertController.addAction(action)
        })
        alertController.addAction(UIAlertAction(title: PGConstants.Strings.cancel.localized, style: .cancel, handler: nil))
        return alertController
    }

    class func alertView(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: PGConstants.Strings.ok.localized, style: .cancel, handler: nil))
        return alertController
    }
}
