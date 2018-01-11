//
//  MusicVideo.swift
//  ASAppleMusic
//
//  Copyright © 2018 Alex Silva. All rights reserved.
//

import Foundation

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/MusicVideo.html

class MusicVideo: Resource {

    // MARK: Resource attributes
    var id: String
    var href: URL
    var meta: [String : Any]?

    // MARK: MusicVideo attributes
    var artistName: String
    var artwork: Artwork
    var contentRating: Rating
    var durationInMillis: Int64?
    var editorialNotes: EditorialNotes?
    var genreNames: [String]
    var isrc: String
    var name: String
    var playParams: Playable?
    var previews: [Preview]
    var releaseDate: String
    var trackNumber: Int?
    var url: URL
    var albums: [Album]
    var artists: [Artist]
    var genres: [Genre]

    init(id: String, href: URL, artistName: String, artwork: Artwork, contentRating: Rating, genreNames: [String], isrc: String, name: String, previews: [Preview], releaseDate: String, url: URL, albums: [Album], artists: [Artist], genres: [Genre]) {
        self.id = id
        self.href = href
        self.artistName = artistName
        self.artwork = artwork
        self.contentRating = contentRating
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
