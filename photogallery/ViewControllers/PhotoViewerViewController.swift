//
//  PhotoViewerViewController.swift
//  photoGallery
//
//  Created by Arup Saha on 12/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PhotoViewerViewController: BaseViewController {
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var shareButton: PGBarButtonItem! {
        didSet {
            shareButton.eventName = "share-button-clicked"
        }
    }
    @IBOutlet fileprivate weak var sliderLabel: PGLabel! {
        didSet {
            sliderLabel.isHidden = true
            sliderLabel.text = PGConstants.Strings.adjustBrightness.localized
        }
    }
    @IBOutlet fileprivate weak var slider: PGSlider! {
        didSet {
            slider.isHidden = true
        }
    }
    @IBOutlet fileprivate weak var progressView: PGProgressView! {
        didSet {
            progressView.isHidden = true
            progressView.progress = initialValueProgressView
        }
    }
    private (set) var shareTargets: [ShareTargetProtocol]?
    fileprivate let initialValueProgressView: Float = 0.5
    fileprivate var editButton: PGBarButtonItem! {
        didSet {
            editButton.eventName = "edit-button-clicked"
        }
    }
    fileprivate weak var shareImageDelegate: ShareImageDelegate?
    fileprivate var imageData: ImageData?
    fileprivate var showSlider: Bool = false {
        didSet {
            let alpha: CGFloat = showSlider ? 1 : 0
            shareButton.isEnabled = !showSlider
            editButton.title = !showSlider ? PGConstants.Strings.edit.localized : PGConstants.Strings.done.localized
            UIView.animate(withDuration: 0.35, animations: {
                self.slider.alpha = alpha
                self.sliderLabel.alpha = alpha
            }) { (_) in
                self.slider.isHidden = !self.showSlider
                self.sliderLabel.isHidden = !self.showSlider
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = (imageData?.image?.copy() as? UIImage)
        title = PGConstants.Strings.photoViewer.localized
        editButton = PGBarButtonItem(title: PGConstants.Strings.edit.localized, style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = editButton
        bindToRX()
    }
    
    convenience init(imageData: ImageData, shareTargets: [ShareTargetProtocol], shareImageDelegate: ShareImageDelegate) {
        self.init(nibName: PhotoViewerViewController.className, bundle: Bundle.main)
        self.imageData = imageData
        self.shareTargets = shareTargets
        self.shareImageDelegate = shareImageDelegate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PhotoViewerViewController {
    fileprivate func bindToRX() {
        editButton.rx.tap.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.showSlider = !self.showSlider
            self.editButton.trackEvent()
        })
        .addDisposableTo(disposeBag)

        slider.rx.value.observeOn(MainScheduler.instance).debounce(0.6, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] (value) in
            guard let `self` = self else { return }
            if !self.slider.isTracking {
                self.imageView.image = self.imageData?.image?.changeBrightness(value - self.initialValueProgressView)
            }
        })
        .addDisposableTo(disposeBag)
        
        shareButton.rx.tap.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            PhotoShareTargetCoordinator(self.navigationController).show(delegate: self, shareTargets: self.shareTargets ?? [])
            self.shareButton.trackEvent()
        })
            .addDisposableTo(disposeBag)
    }
}

extension PhotoViewerViewController: PhotoShareTargetDelegate {
    func didSelectPhotoShareTarget(_ shareTarget: ShareTargetProtocol) {
        let sharingImageData = ImageData(shared: true, image: imageView.image, name: imageData?.name ?? "")
        progressView.isHidden = false
        progressView.setProgress(0.1, animated: true)
        
        shareTarget.upload(text: "", imageData: sharingImageData, controller: self)?
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (status) in
                guard let `self` = self else { return }
                switch status {
                case .completed:
                    self.progressView.isHidden = true
                    self.shareImageDelegate?.sharedSelectedImage(sharingImageData)
                    break
                case .cancelled:
                    self.progressView.isHidden = true
                    break
                case .failed(let description):
                    self.progressView.isHidden = true
                    self.present(ViewFactory.alertView(title: PGConstants.Strings.error.localized, message: description), animated: true, completion: nil)
                    break
                case .progress(let progress):
                    self.progressView.setProgress(Float(progress), animated: true)
                    break
                }
            })
            .addDisposableTo(disposeBag)
    }
}
