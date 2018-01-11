//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import EVReflection

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Artist.html

class Artist: Resource {

    var genreNames: [String]?
    var editorialNotes: EditorialNotes?
    var name: String?
    var url: URL?
    var albums: [Album]?
    var genres: [Genre]?
    var musicVideos: [MusicVideo]?
    var playlists: [Playlist]?
}

