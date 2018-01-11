//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import EVReflection

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Song.html

class Song: EVObject {

    var artistName: String?
    var artwork: Artwork?
    var composerName: String?
    var contentRating: Rating?
    var discNumber: Int?
    var durationInMillis: Int64?
    var editorialNotes: EditorialNotes?
    var genreNames: [String]?
    var isrc: String?
    var movementCount: Int?
    var movementName: String?
    var movementNumber: Int?
    var name: String?
    var playParams: Playable?
    var previews: [Preview]?
    var releaseDate: String?
    var trackNumber: Int?
    var url: URL?
    var workName: String?
    var albums: [Album]?
    var artists: [Artist]?
    var genres: [Genre]?

}

