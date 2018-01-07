//
//  ShareUtility.swift
//  photoGallery
//
//  Created by Arup Saha on 11/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit
import RxSwift

protocol ShareTargetProtocol {
    var target: ShareTarget { get }
    var isInstalled: Bool { get }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
    func handleOpenUrl(app: UIApplication, url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool
    func upload(text: String, imageData: ImageData, controller: UIViewController) -> Observable<UploadTaskStatus>?
}

enum ShareTarget: String {
    case facebook = "Facebook"
    case twitter = "Twitter"
    case dropbox = "Dropbox"
}

enum UploadTaskStatus {
    case completed
    case cancelled
    case failed(String)
    case progress(Double)
}

final class ShareUtility {
    static let instance = ShareUtility()
    private (set) var shareTargets: [ShareTargetProtocol]
    
    private init() {
        shareTargets = [ShareTargetProtocol]()
        shareTargets.append(FacebookUtility())
        shareTargets.append(TwitterUtility())
        shareTargets.append(DropboxUtility())
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        shareTargets.forEach({
            $0.application(application, didFinishLaunchingWithOptions: launchOptions)
        })
    }
    
    func handleOpenUrl(app: UIApplication, url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        for target in shareTargets {
            if target.handleOpenUrl(app: app, url: url, options: options) {
                break
            }
        }
        return true
    }
}
