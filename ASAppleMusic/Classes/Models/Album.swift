//
//  Album.swift
//  ASAppleMusic
//
//  Copyright © 2018 Alex Silva. All rights reserved.
//

import Foundation

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Album.html

class Album: Resource {

    // MARK: Resource attributes
    var id: String
    var href: URL
    var meta: [String : Any]?

    // MARK: Album attributes
    var artistName: String
    var artwork: Artwork
    var contentRating: String?
    var copyright: String
    var editorialNotes: EditorialNotes?
    var genreNames: [String]
    var isComplete: Bool
    var isSingle: Bool
    var name: String
    var recordLabel: String
    var releaseDate: String
    var playParams: Playable?
    var trackCount: Int
    var url: URL
    var playlists: [Playlist]
    var genres: [Genre]
    var tracks: [Resource]

    init(id: String, href: URL, artistName: String, artwork: Artwork, copyright: String, genreNames: [String], isComplete: Bool, isSingle: Bool, name: String, recordLabel: String, releaseDate: String, playParams: Playable, trackCount: Int, url: URL, playlists: [Playlist], genres: [Genre], tracks: [Resource]) {
        self.id = id
        self.href = href
        self.artistName = artistName
        self.artwork = artwork
        self.copyright = copyright
        self.genreNames = genreNames
        self.isComplete = isComplete
        self.isSingle = isSingle
        self.name = name
        self.recordLabel = recordLabel
        self.releaseDate = releaseDate
        self.playParams = playParams
        self.trackCount = trackCount
        self.url = url
        self.playlists = playlists
        self.genres = genres
        self.tracks = tracks
    }
}
