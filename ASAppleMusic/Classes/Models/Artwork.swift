//
//  Artwork.swift
//  ASAppleMusic
//
//  Copyright © 2018 Alex Silva. All rights reserved.
//

import Foundation

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Artwork.html

class Artwork {

    var width: Int
    var height: Int
    var url: URL
    var bgColor: String?
    var textColor1: String?
    var textColor2: String?
    var textColor3: String?
    var textColor4: String?

    init(width: Int, height: Int, url: URL) {
        self.width = width
        self.height = height
        self.url = url
    }
    
}
