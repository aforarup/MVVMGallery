//
//  ImageUtility.swift
//  photoGallery
//
//  Created by Arup Saha on 04/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit
import Kingfisher

protocol ImageUtilityProtocol {
    func store(_ data: ImageData)
    func retrieveAll() -> [ImageData]
    func retrieve(_ forKey: String) -> UIImage?
}

final class ImageUtility: ImageUtilityProtocol {
    fileprivate let dataStore: ImagePersistable
    
    init(dataStore: ImagePersistable) {
        self.dataStore = dataStore
    }
    
    func store(_ data: ImageData) {
        guard let image = data.image else { return }
        KingfisherManager.shared.cache.store(image, forKey: data.name)
        dataStore.saveData(data)
    }
    
    func retrieve(_ forKey: String) -> UIImage? {
        return KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: forKey)
    }
    
    fileprivate func retrieve(_ imageStatus: [ImageData]) -> [ImageData] {
        return imageStatus.flatMap({ return ImageData(shared: $0.shared, image: self.retrieve($0.name), name: $0.name) })
    }
    
    func retrieveAll() -> [ImageData] {
        return retrieve(dataStore.loadData())
    }
}

struct ImageData {
    let shared: Bool
    let image: UIImage?
    let name: String
}
