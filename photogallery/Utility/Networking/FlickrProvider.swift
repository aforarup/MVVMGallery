//
//  FlickrProvider.swift
//  photoGallery
//
//  Created by Arup Saha on 05/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import Moya

typealias Payload = [String: Any]

enum FlickrProvider {
    case interestingList(pageNo: Int)
    case search(pageNo: Int, text: String)
}

let flickrProvider = RxMoyaProvider<FlickrProvider>()

extension FlickrProvider: TargetType {
    var baseURL: URL {
        return  URL(string: PGConstants.Flickr.baseUrl)!
    }
    
    var path: String {
        return ""
    }
    
    var method: Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        var requestParams: Payload = ["api_key": PGConstants.Flickr.apiKey, "format": "json", "nojsoncallback": 1]
        switch self {
        case .interestingList(let pageNo):
            requestParams["method"] = "flickr.interestingness.getList"
            requestParams["page"] = pageNo
        case .search(let pageNo, let text):
            requestParams["method"] = "flickr.photos.search"
            requestParams["text"] = text
            requestParams["page"] = pageNo
        }
        return .requestParameters(parameters: requestParams, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return nil
    }
}
