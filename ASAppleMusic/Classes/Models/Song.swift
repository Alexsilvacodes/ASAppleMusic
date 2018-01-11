//
//  Song.swift
//  ASAppleMusic
//
//  Copyright © 2018 Alex Silva. All rights reserved.
//

import Foundation

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Song.html

class Song: Resource {

    // MARK: Resource attributes
    var id: String
    var href: URL
    var meta: [String : Any]?

    // MARK: Song attributes
    var artistName: String
    var artwork: Artwork
    var composerName: String?
    var contentRating: Rating
    var discNumber: Int
    var durationInMillis: Int64?
    var editorialNotes: EditorialNotes?
    var genreNames: [String]
    var isrc: String
    var movementCount: Int?
    var movementName: String?
    var movementNumber: Int?
    var name: String
    var playParams: Playable?
    var previews: [Preview]
    var releaseDate: String
    var trackNumber: Int?
    var url: URL
    var workName: String?
    var albums: [Album]
    var artists: [Artist]
    var genres: [Genre]

    init(id: String, href: URL, artistName: String, artwork: Artwork, contentRating: Rating, discNumber: Int, genreNames: [String], isrc: String, name: String, previews: [Preview], releaseDate: String, url: URL, albums: [Album], artists: [Artist], genres: [Genre]) {
        self.id = id
        self.href = href
        self.artistName = artistName
        self.artwork = artwork
        self.contentRating = contentRating
        self.discNumber = discNumber
        self.genreNames = genreNames
        self.isrc = isrc
        self.name = name
        self.previews = previews
        self.releaseDate = releaseDate
        self.url = url
        self.albums = albums
        self.artists = artists
        self.genres = genres
    }
}
