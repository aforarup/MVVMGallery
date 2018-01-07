//
//  PGConstants.swift
//  photoGallery
//
//  Created by Arup Saha on 05/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import UIKit

struct PGConstants {
    struct Flickr {
        static let baseUrl = "https://api.flickr.com/services/rest"
        static let apiKey = "ad8e884162d421018526595c55215a4d"
        static let secret = "2a81bff000a3480f"
    }
    
    struct Dropbox {
        static let apiKey = "t678opd3vfxrq39"
        static let secret = "t8acwa3rygb2lz8"
    }
    
    struct Twitter {
        static let apiKey = "TqBTd5jukORIJenNTKcZTXJEa"
        static let secret = "c02VgGWDReh8eCZG0OcYhD0iF1v4lMTK1Bx6UOD9DYc7T2T9ak"
    }
    
    struct Strings {
        static let gallery = "Gallery"
        static let photo = "photo"
        static let photos = "photos"
        static let camera = "Camera"
        static let photoLibrary = "Photo Library"
        static let flickr = "Flickr"
        static let facebook = "Facebook"
        static let twitter = "Twitter"
        static let dropbox = "Dropbox"
        static let flickrPhotos = "Flickr Photos"
        static let error = "Error"
        static let cancel = "Cancel"
        static let loading = "Loading..."
        static let ok = "OK"
        static let shared = "Shared"
        static let notShared = "Not Shared"
        static let flickrPhotoSearch = "Search photos on Flickr"
        static let credits = "Credits"
        static let appIcon = "App Icon"
        static let dropboxNotInstalled = "Dropbox is not installed"
        static let facebookNotInstalled = "Facebook is not installed"
        static let twitterNotInstalled = "Twitter is not installed"
        static let photoViewer = "Photo Viewer"
        static let edit = "Edit"
        static let done = "Done"
        static let adjustBrightness = "Adjust brightness by moving the slider"
    }
}
