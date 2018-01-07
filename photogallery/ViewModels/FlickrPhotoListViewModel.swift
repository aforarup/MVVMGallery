//
//  FlickrPhotoListViewModel.swift
//  photoGallery
//
//  Created by Arup Saha on 05/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import Kingfisher

class FlickrPhotoListViewModel: BaseViewModel {
    var images: Observable<[FlickrPhotoSectionData]>!
    fileprivate let nextPage = PublishSubject<Int>()
    
    fileprivate var allImages = [FlickrPhoto]()
    fileprivate var interestingPhotos: [FlickrPhoto] = []
    fileprivate var metaData = FlickrResponseMetaData()
    
    private (set) var selectedIndexPath = Variable<IndexPath!>(nil)

    var selectedItem: FlickrPhoto? {
        guard let indexPath = selectedIndexPath.value else { return nil }
        return getImageAtIndexPath(indexPath: indexPath)
    }

    func getImageAtIndexPath(indexPath: IndexPath) -> FlickrPhoto? {
        guard indexPath.row <= allImages.count else {
            return nil
        }
        return allImages[indexPath.row]
    }

    init(provider: RxMoyaProvider<FlickrProvider>, searchText: Driver<String>) {
        super.init()
        
        _ = searchText.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (query) in
                self?.allImages = []
                self?.metaData = FlickrResponseMetaData()
            })
            .addDisposableTo(disposeBag)
        
        images = Observable.combineLatest(nextPage.asObservable().distinctUntilChanged().startWith(1), searchText.debounce(0.6).distinctUntilChanged().asObservable().startWith("")) { ($0, $1)}
            .filter({ (_, query) in
                return (query.isEmpty || (query.characters.count > 2))
            })
            .flatMapLatest({ [weak self] (pageNo, query) -> Observable<[FlickrPhoto]> in
                guard let `self` = self else { return Observable.just([]) }
                if query.isEmpty && !self.interestingPhotos.isEmpty && pageNo == 1 {
                    return Observable.just(self.interestingPhotos)
                } else {
                    return provider.requestWithoutError(query.isEmpty ? .interestingList(pageNo: pageNo): .search(pageNo: pageNo, text: query))
                            .asObservable()
                            .mapToModel(FlickrPhotoResponse.self)
                            .map({ [weak self] (result) in
                                switch result {
                                case .success(let response):
                                    guard let `self` = self else { return [] }
                                    self.allImages = self.allImages + response.photos
                                    if self.interestingPhotos.isEmpty {
                                        self.interestingPhotos = response.photos
                                    }
                                    self.metaData = response.metaData
                                    return self.allImages
                                case .failure(_):
                                    //Send error to view
                                    return []
                                }
                            })
                }
            })
            .map({ (photos) -> [FlickrPhotoSectionData] in
                return [FlickrPhotoSectionData(header: "", items: photos)]
            })
    }
    
    func getNextPage() {
        if !allImages.isEmpty {
            nextPage.onNext(metaData.page+1)
        }
    }
}
