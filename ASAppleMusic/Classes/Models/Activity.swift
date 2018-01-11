//
//  Activity.swift
//  ASAppleMusic
//
//  Copyright © 2018 Alex Silva. All rights reserved.
//

import Foundation

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Activity.html

class Activity: Resource {

    // MARK: Resource attributes
    var id: String
    var href: URL
    var meta: [String : Any]?

    // MARK: Activity attributes
    var artwork: Artwork
    var editorialNotes: EditorialNotes?
    var name: String
    var url: URL
    var playlists: [Playlist]

    init(id: String, href: URL, artwork: Artwork, name: String, url: URL, playlists: [Playlist]) {
        self.id = id
        self.href = href
        self.artwork = artwork
        self.name = name
        self.url = url
        self.playlists = playlists
    }
}
