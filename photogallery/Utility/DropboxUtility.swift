//
//  DropboxUtility.swift
//  photoGallery
//
//  Created by Arup Saha on 09/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit
import SwiftyDropbox
import RxSwift
import Alamofire

final class DropboxUtility: NSObject {
    fileprivate var subscribe: BehaviorSubject<UploadTaskStatus>!
    fileprivate var client: DropboxClient?
    fileprivate var data: Data!
    fileprivate var path = ""
    
    let target = ShareTarget.dropbox
    var isInstalled: Bool {
        return (UIApplication.shared.canOpenURL(URL(string: "dbapi-2://")!) || UIApplication.shared.canOpenURL(URL(string: "dbapi-8-emm://")!))
    }
    
    override init() {
        DropboxClientsManager.setupWithAppKey(PGConstants.Dropbox.apiKey)
        client = DropboxClientsManager.authorizedClient
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
    }

    func upload(text: String, imageData: ImageData, controller: UIViewController) -> Observable<UploadTaskStatus>? {
        guard let image = imageData.image else {
            return nil
        }
        self.data = UIImagePNGRepresentation(image)
        self.path = "/\(imageData.name).png"
        subscribe = BehaviorSubject<UploadTaskStatus>(value: .progress(0))
        if !isInstalled {
            subscribe.onNext(UploadTaskStatus.failed(PGConstants.Strings.dropboxNotInstalled.localized))
        } else if client == nil {
            authorize(controller: controller)
        } else {
            upload(path: path, data: data)
        }
        return subscribe.asObservable()
    }
    
    fileprivate func authorize(controller: UIViewController) {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: nil,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        })
    }
    
    fileprivate func upload(path: String, data: Data) {
            _ = client?.files.upload(path: path, input: data)
                .response(completionHandler: { [weak self] (response, error) in
                    if let _ = response {
                        self?.subscribe.onNext(UploadTaskStatus.completed)
                        self?.subscribe.onCompleted()
                    } else if let error = error {
                        self?.subscribe.onNext(UploadTaskStatus.failed(error.description))
                        self?.subscribe.onCompleted()
                    }
                })
                .progress { [weak self] progressData in
                    self?.subscribe.onNext(UploadTaskStatus.progress(progressData.fractionCompleted))
                }
    }
    
    func handleOpenUrl(app: UIApplication, url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success(let token):
                client = DropboxClient(accessToken: token.accessToken)
                if let data = data {
                    upload(path: path, data: data)
                }
            case .cancel:
                subscribe.onNext(UploadTaskStatus.cancelled)
                subscribe.onCompleted()
            case .error(_, let description):
                subscribe.onNext(UploadTaskStatus.failed(description))
                subscribe.onCompleted()
            }
        }
        return true
    }
}

extension DropboxUtility: ShareTargetProtocol {
}
