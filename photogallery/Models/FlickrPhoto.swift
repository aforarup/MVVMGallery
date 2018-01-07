//
//  FlickrPhoto.swift
//  photoGallery
//
//  Created by Arup Saha on 05/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON
import RxDataSources

struct FlickrPhotoResponse: JSONMappable {
    let metaData: FlickrResponseMetaData
    let photos: [FlickrPhoto]
    
    init(json: JSON) {
        metaData = FlickrResponseMetaData(json: json["photos"])
        photos = json["photos"]["photo"].arrayValue.map({ return FlickrPhoto(json: $0) })
    }
}

struct FlickrResponseMetaData: JSONMappable {
    let page: Int
    let pages: Int
    let perpage: Int
    
    init(json: JSON) {
        page = json["page"].intValue
        pages = json["pages"].intValue
        perpage = json["perpage"].intValue
    }
    
    init() {
        page = 1
        pages = 1
        perpage = 100
    }
}

struct FlickrPhoto: JSONMappable {
    let id: String
    let secret: String
    let server: String
    let farm: String
    
    init(json: JSON) {
        id = json["id"].stringValue
        secret = json["secret"].stringValue
        server = json["server"].stringValue
        farm = json["farm"].stringValue
    }
    
    func getPhotoUrl(size: Int) -> String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(FlickrPhotoSize(size: size).rawValue).jpg"
    }
    
    func getPhotoUrl(size: Int) -> URL {
        return URL(string: getPhotoUrl(size: size))!
    }
}

struct PhotoGallerySectionData {
    var header: String
    var items: [Item]
}

extension PhotoGallerySectionData: SectionModelType {
    typealias Item = ImageData
    
    init(original: PhotoGallerySectionData, items: [Item]) {
        self = original
        self.items = items
    }
}

struct FlickrPhotoSectionData {
    var header: String
    var items: [Item]
}

extension FlickrPhotoSectionData: SectionModelType {
    typealias Item = FlickrPhoto
    
    init(original: FlickrPhotoSectionData, items: [Item]) {
        self = original
        self.items = items
    }
}

enum FlickrPhotoSize: String {
    case s
    case q
    case t
    case m
    case n
    case z
    case c
    case b
    case h
    case k
    
    init(size: Int) {
        switch size {
        case 1..<75:
            self = .s
        case 75..<100:
            self = .t
        case 100..<150:
            self = .q
        case 150..<240:
            self = .m
        case 240..<320:
            self = .n
        case 320..<640:
            self = .z
        case 640..<800:
            self = .c
        case 800..<1024:
            self = .b
        case 1024..<1600:
            self = .h
        case 1600..<2048:
            self = .k
        default:
            self = .m
        }
    }
}
