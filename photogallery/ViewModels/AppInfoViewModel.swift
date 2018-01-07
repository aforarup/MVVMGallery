//
//  AppInfoViewModel.swift
//  photoGallery
//
//  Created by Arup Saha on 11/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

typealias InfoDictionary = (title: String, description: String)
final class AppInfoViewModel: BaseViewModel {
    var infoDriver: Driver<[InfoDictionary]> {
        return infoVariable.asDriver()
    }
    
    fileprivate var infoVariable = Variable<[InfoDictionary]>([])
    
    override init() {
        super.init()
        infoVariable.value = [(title: PGConstants.Strings.appIcon.localized, description: "https://icons8.com/icon/18915/ios-photos")]
    }
}
