//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import EVReflection

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Album.html

class Album: EVObject {

    var artistName: String?
    var artwork: Artwork?
    var contentRating: String?
    var copyright: String?
    var editorialNotes: EditorialNotes?
    var genreNames: [String]?
    var isComplete: Bool?
    var isSingle: Bool?
    var name: String?
    var recordLabel: String?
    var releaseDate: String?
    var playParams: Playable?
    var trackCount: Int?
    var url: URL?
    var playlists: [Playlist]?
    var genres: [Genre]?
    var tracks: [Resource]?
}

