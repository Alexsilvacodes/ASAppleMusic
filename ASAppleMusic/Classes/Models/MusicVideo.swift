//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import EVReflection

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/MusicVideo.html

class MusicVideo: EVObject {

    var artistName: String?
    var artwork: Artwork?
    var contentRating: Rating?
    var durationInMillis: Int64?
    var editorialNotes: EditorialNotes?
    var genreNames: [String]?
    var isrc: String?
    var name: String?
    var playParams: Playable?
    var previews: [Preview]?
    var releaseDate: String?
    var trackNumber: Int?
    var url: URL?
    var albums: [Album]?
    var artists: [Artist]?
    var genres: [Genre]?
}

