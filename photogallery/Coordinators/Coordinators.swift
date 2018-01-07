//
//  Coordinators.swift
//  photoGallery
//
//  Created by Arup Saha on 04/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit

class Coordinator {
    var childCoordinators: [Coordinator] = []
    weak var navigationController: UINavigationController?
    
    init(_ navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    init() {
    }
}

final class PhotoGalleryCoordinator: Coordinator {
    func show() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let navC = UINavigationController(rootViewController: PhotoGalleryViewController(viewModel: PhotoGalleryViewModel(imageUtility: ImageUtility(dataStore: CoreDataImageNameUtility()))))
        window.rootViewController = navC
        window.makeKeyAndVisible()
        (UIApplication.shared.delegate as! AppDelegate).window = window
    }
}

final class PhotoSourceCoordinator: Coordinator {
    func show(delegate: PhotoSourceDelegate) {
        navigationController?.topViewController?.present(ViewFactory.getPhotoSourceAlertController([.camera, .library, .flickr], delegate: delegate), animated: true, completion: nil)
    }
}

final class ImagePickerCoordinator: Coordinator {
    func show(source: PhotoSource, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = delegate
            imagePicker.sourceType = ((source == .camera) ? .camera : .photoLibrary)
            imagePicker.allowsEditing = true
            navigationController?.topViewController?.present(imagePicker, animated: true, completion: nil)
        }
    }
}

final class FlickrPhotoViewerCoordinator: Coordinator {
    func show(addImageDelegate: AddNewImageDelegate) {
        let vc = FlickrPhotoListViewController(addImageDelegate: addImageDelegate)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        let navC = UINavigationController(rootViewController: vc)
        navigationController?.present(navC, animated: true, completion: nil)
    }
}

final class PhotoShareTargetCoordinator: Coordinator {
    func show(delegate: PhotoShareTargetDelegate, shareTargets: [ShareTargetProtocol]) {
        navigationController?.topViewController?.present(ViewFactory.getShareTargetAlertController(shareTargets, delegate: delegate), animated: true, completion: nil)
    }
}

final class AppInfoCoordinator: Coordinator {
    func show() {
        navigationController?.pushViewController(AppInfoViewController(viewModel: AppInfoViewModel()), animated: true)
    }
}

final class PhotoViewerCoordinator: Coordinator {
    func show(imageData: ImageData, delegate: ShareImageDelegate) {
        navigationController?.pushViewController(PhotoViewerViewController(imageData: imageData, shareTargets: ShareUtility.instance.shareTargets, shareImageDelegate: delegate), animated: true)
    }
}
