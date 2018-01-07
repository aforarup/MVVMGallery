//
//  PhotoGalleryViewModel.swift
//  photoGallery
//
//  Created by Arup Saha on 04/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class BaseViewModel {
    let disposeBag: DisposeBag
    init() {
        disposeBag = DisposeBag()
    }
}

protocol AddNewImageDelegate: class {
    func addNewImage(_ image: UIImage)
}

protocol ShareImageDelegate: class {
    func sharedSelectedImage(_ imageData: ImageData)
}


final class PhotoGalleryViewModel: BaseViewModel {
    fileprivate let imageUtility: ImageUtilityProtocol
    var images: Observable<[PhotoGallerySectionData]> {
        return imageVariable.asObservable()
    }
    
    var numberOfItems: Int {
        return imageVariable.value.reduce(0, { (result, data) -> Int in
            result + data.items.count
        })
    }
    
    private (set) var selectedIndexPath = Variable<IndexPath!>(nil)
    
    fileprivate let imageVariable = Variable<[PhotoGallerySectionData]>([])
    
    init(imageUtility: ImageUtilityProtocol) {
        self.imageUtility = imageUtility
        let allImageData = imageUtility.retrieveAll()
        let shared = allImageData.filter({ $0.shared })
        let notShared = allImageData.filter({ !$0.shared })
        var sectionedData = [PhotoGallerySectionData]()
        if notShared.count > 0 {
            sectionedData.append(PhotoGallerySectionData(header: PGConstants.Strings.notShared.localized, items: allImageData.filter({ !$0.shared })))
        }
        if shared.count > 0 {
            sectionedData.append(PhotoGallerySectionData(header: PGConstants.Strings.shared.localized, items: allImageData.filter({ $0.shared })))
        }
        imageVariable.value = sectionedData
        super.init()
    }
    
    func getImageAtIndexPath(indexPath: IndexPath) -> ImageData? {
        guard indexPath.section <= imageVariable.value.count else {
            return nil
        }
        return imageVariable.value[indexPath.section].items[indexPath.row]
    }
    
    var selectedItem: ImageData? {
        guard let indexPath = selectedIndexPath.value else { return nil }
        return getImageAtIndexPath(indexPath: indexPath)
    }
    
    func sharedSelectedImage(_ imageData: ImageData) {
        guard let indexPath = selectedIndexPath.value else { return }
        var sharedItems = (imageVariable.value.count == 2) ? imageVariable.value[1] : PhotoGallerySectionData(header: PGConstants.Strings.shared.localized, items: [])
        if indexPath.section == 1 {
            sharedItems.items[indexPath.row] = imageData
        } else {
            sharedItems.items.append(imageData)
        }
        if imageVariable.value.count == 1 {
            imageVariable.value.append(sharedItems)
        } else {
            imageVariable.value[1] = sharedItems
        }
        imageUtility.store(ImageData(shared: true, image: imageData.image, name: imageData.name))
        var unSharedItems = imageVariable.value[0]
        guard indexPath.section == 0 else { return }
        unSharedItems.items.remove(at: indexPath.row)
        imageVariable.value[0] = unSharedItems
        selectedIndexPath.value = IndexPath(row: sharedItems.items.count - 1, section: 1)
        //, unSharedItems.items.count > indexPath.row, unSharedItems.items[indexPath.row].name == imageData.name
    }
    
    func addNewImage(_ image: UIImage) {
        let imageData = ImageData(shared: false, image: image, name: UUID().uuidString)
        imageUtility.store(imageData)
        var unSharedItems = imageVariable.value.first ?? PhotoGallerySectionData(header: PGConstants.Strings.notShared.localized, items: [])
        unSharedItems.items.append(imageData)
        if imageVariable.value.isEmpty {
            imageVariable.value.append(unSharedItems)
        } else {
            imageVariable.value[0] = unSharedItems
        }
    }
}

extension PhotoGalleryViewModel: AddNewImageDelegate {
}

extension PhotoGalleryViewModel: ShareImageDelegate {
}
