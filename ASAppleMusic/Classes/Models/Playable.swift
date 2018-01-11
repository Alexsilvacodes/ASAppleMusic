//
//  Playable.swift
//  ASAppleMusic
//
//  Copyright © 2018 Alex Silva. All rights reserved.
//

import Foundation

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Playable.html

class Playable {

    var id: String
    var kind: String

    init(id: String, kind: String) {
        self.id = id
        self.kind = kind
    }

}
