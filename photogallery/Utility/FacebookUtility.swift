//
//  FacebookUtility.swift
//  photoGallery
//
//  Created by Arup Saha on 10/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import RxSwift

final class FacebookUtility: NSObject {
    fileprivate var subscribe: BehaviorSubject<UploadTaskStatus>!
    let target = ShareTarget.facebook
    var isInstalled: Bool {
        return UIApplication.shared.canOpenURL(URL(string: "fbauth2://")!)
    }

    override init() {
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func handleOpenUrl(app: UIApplication, url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: (options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String) ?? "", annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func upload(text: String, imageData: ImageData, controller: UIViewController) -> Observable<UploadTaskStatus>? {
        guard let image = imageData.image else {
            return nil
        }
        subscribe = BehaviorSubject<UploadTaskStatus>(value: .progress(0))
        if isInstalled {
            let content = FBSDKSharePhotoContent()
            let fbPhoto: FBSDKSharePhoto = FBSDKSharePhoto(image: image, userGenerated: true)
            fbPhoto.caption = text
            content.photos = [fbPhoto]
            FBSDKShareDialog.show(from: controller, with: content, delegate: self).show()
        } else {
            subscribe.onNext(UploadTaskStatus.failed(PGConstants.Strings.facebookNotInstalled.localized))
        }
        return subscribe.asObservable()
    }
}

extension FacebookUtility: FBSDKSharingDelegate {
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        subscribe.onNext(.cancelled)
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        subscribe.onNext(.failed(error.localizedDescription))
    }
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        subscribe.onNext(.completed)
    }
}

extension FacebookUtility: ShareTargetProtocol {
}
