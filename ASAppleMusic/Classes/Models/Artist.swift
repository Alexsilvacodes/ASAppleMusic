//
//  Artist.swift
//  ASAppleMusic
//
//  Copyright © 2018 Alex Silva. All rights reserved.
//

import Foundation

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Artist.html

class Artist: Resource {

    // MARK: Resource attributes
    var id: String
    var href: URL
    var meta: [String : Any]?

    // MARK: Artist attributes
    var genreNames: [String]
    var editorialNotes: EditorialNotes?
    var name: String
    var url: URL
    var albums: [Album]
    var genres: [Genre]
    var musicVideos: [MusicVideo]
    var playlists: [Playlist]

    init(id: String, href: URL, genreNames: [String], name: String, url: URL, albums: [Album], genres: [Genre], musicVideos: [MusicVideo], playlists: [Playlist]) {
        self.id = id
        self.href = href
        self.genreNames = genreNames
        self.name = name
        self.url = url
        self.albums = albums
        self.genres = genres
        self.musicVideos = musicVideos
        self.playlists = playlists
    }
}
