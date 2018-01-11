//
//  EditorialNotes.swift
//  ASAppleMusic
//
//  Copyright © 2018 Alex Silva. All rights reserved.
//

import Foundation

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/EditorialNotes.html

class EditorialNotes {

    var standard: String
    var short: String

    init(standard: String, short: String) {
        self.standard = standard
        self.short = short
    }
}
