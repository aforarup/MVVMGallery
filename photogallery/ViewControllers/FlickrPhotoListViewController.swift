//
//  FlickrPhotoListViewController.swift
//  photoGallery
//
//  Created by Arup Saha on 05/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Kingfisher

final class FlickrPhotoListViewController: BaseViewController {
    @IBOutlet fileprivate weak var collectionView: PGCollectionView! {
        didSet {
            collectionView.register(UINib(nibName: PhotoCollectionViewCell.className, bundle: Bundle.main), forCellWithReuseIdentifier: PhotoCollectionViewCell.className)
            collectionView.register(UINib(nibName: FetchNextReusableView.className, bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: FetchNextReusableView.className)
            collectionView.delegate = self
        }
    }
    @IBOutlet fileprivate weak var progressView: PGProgressView! {
        didSet {
            progressView.isHidden = true
        }
    }
    @IBOutlet fileprivate weak var searchBar: PGSearchBar! {
        didSet {
            searchBar.placeholder = PGConstants.Strings.flickrPhotoSearch.localized
        }
    }
    fileprivate var viewModel: FlickrPhotoListViewModel!
    fileprivate var cancelButton: PGBarButtonItem! {
        didSet {
            cancelButton.eventName = "cancel-button-clicked"
        }
    }
    fileprivate let dataSource = RxCollectionViewSectionedReloadDataSource<FlickrPhotoSectionData>()
    fileprivate weak var addImageDelegate: AddNewImageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = PGConstants.Strings.flickrPhotos.localized
        cancelButton = PGBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
        navigationItem.rightBarButtonItem = cancelButton
        bindToRx()
        // Do any additional setup after loading the view.
    }
    
    convenience init(addImageDelegate: AddNewImageDelegate) {
        self.init(nibName: FlickrPhotoListViewController.className, bundle: Bundle.main)
        self.addImageDelegate = addImageDelegate
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FlickrPhotoListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getItemSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionFooter {
            viewModel.getNextPage()
        }
    }
    
    fileprivate func getItemSize() -> CGSize {
        let dimension = (collectionView.bounds.width - 3)/4
        return CGSize(width: dimension, height: dimension)
    }
}

extension FlickrPhotoListViewController {
    fileprivate func bindToRx() {
        viewModel = FlickrPhotoListViewModel(provider: flickrProvider, searchText: searchBar.rx.text.orEmpty.changed.asDriver())
        
        dataSource.configureCell = { [weak self] (_, collectionView, indexPath, item) in
            let cell: PhotoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.className, for: indexPath) as! PhotoCollectionViewCell
            if let `self` = self {
                cell.urlString = item.getPhotoUrl(size: Int(self.getItemSize().width * UIScreen.main.scale))
            }
            return cell
        }
        
        dataSource.supplementaryViewFactory = { (dataSource ,collectionView, type, indexPath) in
            let section = collectionView.dequeueReusableSupplementaryView(ofKind: type, withReuseIdentifier: FetchNextReusableView.className, for: indexPath) as! FetchNextReusableView
            return section
        }
        
        collectionView.rx.itemSelected.asDriver()
            .drive(onNext: { [weak self] (indexPath) in
                self?.viewModel.selectedIndexPath.value = indexPath
                guard let flickrPhoto = self?.viewModel.selectedItem, let `self` = self else { return }
                KingfisherManager.shared.downloader.downloadImage(with: flickrPhoto.getPhotoUrl(size: Int(self.view.bounds.width)), retrieveImageTask: nil, options: nil, progressBlock: { [weak self] (received, total) in
                    self?.progressView.isHidden = false
                    self?.progressView.setProgress(Float(received/total), animated: true)
                }, completionHandler: { [weak self] (image, error, _, _) in
                    self?.progressView.isHidden = true
                    if let error = error {
                        self?.present(ViewFactory.alertView(title: PGConstants.Strings.error.localized, message: error.localizedDescription), animated: true, completion: nil)
                    } else if let image = image {
                        self?.addImageDelegate?.addNewImage(image)
                        self?.dismiss(animated: true, completion: nil)
                    }
                })
            })
            .addDisposableTo(disposeBag)
        
        viewModel.images
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        cancelButton.rx.tap.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            self?.navigationController?.dismiss(animated: true, completion: nil)
            self?.cancelButton.trackEvent()
        })
        .addDisposableTo(disposeBag)
        
        searchBar.rx.text.orEmpty.changed.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (query) in
                self?.collectionView.setContentOffset(.zero, animated: false)
            })
            .addDisposableTo(disposeBag)
    }
}
