//
//  Playlist.swift
//  ASAppleMusic
//
//  Copyright © 2018 Alex Silva. All rights reserved.
//

import Foundation

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Playlist.html

enum PlaylistType {
    case userShared
    case editorial
    case external
    case personalMix
}

class Playlist: Resource {

    // MARK: Resource attributes
    var id: String
    var href: URL
    var meta: [String : Any]?

    // MARK: Playlist attributes
    var artwork: Artwork?
    var curatorName: String?
    var description: EditorialNotes?
    var lastModifiedDate: String
    var name: String
    var playlistType: PlaylistType
    var playParams: Playable?
    var url: URL
    var curator: [Curator]
    var tracks: [Resource]

    init(id: String, href: URL, lastModifiedDate: String, name: String, playlistType: PlaylistType, url: URL, curator: [Curator], tracks: [Resource]) {
        self.id = id
        self.href = href
        self.lastModifiedDate = lastModifiedDate
        self.name = name
        self.playlistType = playlistType
        self.url = url
        self.curator = curator
        self.tracks = tracks
    }
}
