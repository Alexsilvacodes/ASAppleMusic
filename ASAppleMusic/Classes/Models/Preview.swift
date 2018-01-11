//
//  Preview.swift
//  ASAppleMusic
//
//  Copyright © 2018 Alex Silva. All rights reserved.
//

import Foundation

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Preview.html

class Preview {

    var url: String
    var artwork: Artwork?

    init(url: String) {
        self.url = url
    }

}
