//
//  PGCollectionView.swift
//  photoGallery
//
//  Created by Arup Saha on 04/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol AnalyticsProtocol {
    var eventName: String { get set }
    var eventDetails: Payload { get set }
}

extension AnalyticsProtocol {
    func trackEvent() {
        AnalyticsUtility.trackEvent(eventName, details: eventDetails)
    }
}

final class PGCollectionView: UICollectionView {
}

final class PGTableView: UITableView {
}

final class PGCollectionViewCell: UICollectionViewCell {
}

class PGTableViewCell: UITableViewCell {
}

final class PGLabel: UILabel {
}

final class PGToolbar: UIToolbar {
}

final class PGBarButtonItem: UIBarButtonItem, AnalyticsProtocol {
    @IBInspectable var eventName: String = ""
    var eventDetails: Payload = [:]
}

final class PGSearchBar: UISearchBar {
}

final class PGProgressView: UIProgressView {
}

final class PGSlider: UISlider {
}

final class PGButton: UIButton, AnalyticsProtocol {
    @IBInspectable var eventName: String = ""
    var eventDetails: Payload = [:]
}
