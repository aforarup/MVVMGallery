//
//  FoundationExtension.swift
//  photoGallery
//
//  Created by Arup Saha on 04/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import Foundation

extension NSObject {
    class var className: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
