//
//  PhotoGalleryViewController.swift
//  photoGallery
//
//  Created by Arup Saha on 04/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class PhotoGalleryViewController: BaseViewController {
    @IBOutlet fileprivate weak var collectionView: PGCollectionView! {
        didSet {
            collectionView.register(UINib(nibName: PhotoCollectionViewCell.className, bundle: Bundle.main ), forCellWithReuseIdentifier: PhotoCollectionViewCell.className)
            collectionView.register(UINib(nibName: CollectionViewHeader.className, bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewHeader.className)
            collectionView.delegate = self
        }
    }
    @IBOutlet fileprivate weak var toolBar: PGToolbar!
    @IBOutlet fileprivate weak var addButton: PGBarButtonItem! {
        didSet {
            addButton.eventName = "add-button-clicked"
        }
    }
    @IBOutlet fileprivate weak var organiseButton: PGBarButtonItem! {
        didSet {
            organiseButton.eventName = "organise-button-clicked"
        }
    }
    @IBOutlet fileprivate weak var infoLabel: PGLabel!
    fileprivate var itemCount: Int = 0 {
        didSet {
            infoLabel.text = "\(itemCount) \(itemCount == 1 ? PGConstants.Strings.photo.localized : PGConstants.Strings.photos.localized)"
        }
    }
    fileprivate var appInfoButton: PGButton! {
        didSet {
            appInfoButton.eventName = "app-info-button-clicked"
        }
    }
    fileprivate var viewModel: PhotoGalleryViewModel!
    
    fileprivate var gridType: GridType = .four {
        didSet {
            collectionView.performBatchUpdates(nil, completion: nil)
        }
    }
    fileprivate let dataSource = RxCollectionViewSectionedReloadDataSource<PhotoGallerySectionData>()
    fileprivate let transition = PopAnimationController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = PGConstants.Strings.gallery.localized
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        appInfoButton = PGButton(type: .infoDark)
        navigationItem.leftBarButtonItem = PGBarButtonItem(customView: appInfoButton)
        bindToRx()
        navigationController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    convenience init(viewModel: PhotoGalleryViewModel) {
        self.init(nibName: PhotoGalleryViewController.className, bundle: Bundle.main)
        self.viewModel = viewModel
    }
}

extension PhotoGalleryViewController {
    enum GridType: Int {
        case one = 1
        case two
        case three
        case four
        
        func next(_ items: Int) -> GridType {
            let maxGridSize = min(items, 4)
            return GridType(rawValue: (self.rawValue)%maxGridSize  + 1)!
        }
    }
}

extension PhotoGalleryViewController {
    fileprivate func bindToRx() {
        dataSource.configureCell = { (_, collectionView, indexPath, item) in
            let cell: PhotoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.className, for: indexPath) as! PhotoCollectionViewCell
            cell.image = item.image
            return cell
        }
        
        dataSource.supplementaryViewFactory = { (dataSource ,collectionView, type, indexPath) in
            let section = collectionView.dequeueReusableSupplementaryView(ofKind: type, withReuseIdentifier: CollectionViewHeader.className, for: indexPath) as! CollectionViewHeader
            section.text = dataSource[indexPath.section].header
            return section
        }
        
        viewModel.images
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

        viewModel.images.subscribe(onNext: { [weak self] (_) in
            guard let `self` = self else { return }
            self.itemCount = self.viewModel.numberOfItems
            self.organiseButton.isEnabled = (self.itemCount > 0)
        })
        .addDisposableTo(disposeBag)
        
        collectionView.rx.itemSelected.asDriver()
            .drive(onNext: { [weak self] (indexPath) in
                guard let `self` = self else { return }
                self.viewModel.selectedIndexPath.value = indexPath
                guard let selectedImageData = self.viewModel.selectedItem else { return }
                PhotoViewerCoordinator(self.navigationController).show(imageData: selectedImageData, delegate: self.viewModel)
            })
            .addDisposableTo(disposeBag)

        addButton.rx.tap.observeOn(MainScheduler.instance).subscribe { [weak self] _ in
            guard let `self` = self else { return }
            PhotoSourceCoordinator(self.navigationController).show(delegate: self)
            self.addButton.trackEvent()
        }
        .addDisposableTo(disposeBag)
        organiseButton.rx.tap.observeOn(MainScheduler.instance).subscribe { [weak self] _ in
            guard let `self` = self else { return }
            self.gridType = self.gridType.next(self.itemCount)
            self.organiseButton.trackEvent()
        }
        .addDisposableTo(disposeBag)
        appInfoButton.rx.tap.subscribe { [weak self] _ in
            AppInfoCoordinator(self?.navigationController).show()
            self?.appInfoButton.trackEvent()
        }
        .addDisposableTo(disposeBag)
    }
    
    fileprivate func getCollectionViewItemSize(_ collectionView: UICollectionView, gridType: GridType, itemCount: Int) -> CGSize {
        let numberofItems = CGFloat(min(itemCount, gridType.rawValue))
        let dimension = (collectionView.bounds.width - (numberofItems - 1))/numberofItems
        return CGSize(width: dimension, height: dimension)
    }
}

extension PhotoGalleryViewController: PhotoSourceDelegate {
    func didSelectPhotoSouce(_ source: PhotoSource) {
        switch source {
        case .camera:
            fallthrough
        case .library:
            ImagePickerCoordinator(navigationController).show(source: source, delegate: self)
        case .flickr:
            FlickrPhotoViewerCoordinator(navigationController).show(addImageDelegate: viewModel)
            break
        }
    }
}

extension PhotoGalleryViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        viewModel.addNewImage(image)
        dismiss(animated: true, completion: nil)
    }
}

extension PhotoGalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getCollectionViewItemSize(collectionView, gridType: gridType, itemCount: itemCount)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension PhotoGalleryViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC.isKind(of: PhotoViewerViewController.self) || fromVC.isKind(of: PhotoViewerViewController.self) {
            if operation == .push, let cell = collectionView.cellForItem(at: viewModel.selectedIndexPath.value) {
                transition.origin = collectionView.convert(cell.frame, to: nil)
            }
            transition.presenting = (operation == .push)
            return transition
        } else {
            return nil
        }
    }
}

enum PhotoSource: String {
    case camera = "Camera"
    case library = "Photo Library"
    case flickr = "Flickr"
}

protocol PhotoSourceDelegate: class {
    func didSelectPhotoSouce(_ source: PhotoSource)
}

protocol PhotoShareTargetDelegate: class {
    var shareTargets: [ShareTargetProtocol]? { get }
    func didSelectPhotoShareTarget(_ shareTarget: ShareTargetProtocol)
}
