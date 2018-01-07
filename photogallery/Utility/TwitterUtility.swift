//
//  TwitterUtility.swift
//  photoGallery
//
//  Created by Arup Saha on 10/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit
import TwitterKit
import RxSwift

final class TwitterUtility: NSObject {
    fileprivate var composer: TWTRComposer!
    fileprivate var subscribe: BehaviorSubject<UploadTaskStatus>!
    let target = ShareTarget.twitter
    
    var isInstalled: Bool {
        return UIApplication.shared.canOpenURL(URL(string: "twitter://")!)
    }

    override init() {
        Twitter.sharedInstance().start(withConsumerKey: PGConstants.Twitter.apiKey, consumerSecret: PGConstants.Twitter.secret)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        
    }
    
    func handleOpenUrl(app: UIApplication, url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return Twitter.sharedInstance().application(app, open: url, options: options)
    }
    
    func upload(text: String, imageData: ImageData, controller: UIViewController) -> Observable<UploadTaskStatus>? {
        subscribe = BehaviorSubject<UploadTaskStatus>(value: .progress(0))
        if isInstalled {
            composer = TWTRComposer()
            composer.setText(text)
            composer.setImage(imageData.image)
            show(controller: controller)
        } else {
            subscribe.onNext(UploadTaskStatus.failed(PGConstants.Strings.twitterNotInstalled.localized))
        }
        return subscribe.asObservable()
    }
    
    fileprivate func show(controller: UIViewController) {
        composer.show(from: controller) { [weak self] (result) in
            if (result == .done) {
                self?.subscribe.onNext(.completed)
            } else {
                self?.subscribe.onNext(.cancelled)
            }
            self?.subscribe.onCompleted()
        }
    }
}

extension TwitterUtility: ShareTargetProtocol {
}
