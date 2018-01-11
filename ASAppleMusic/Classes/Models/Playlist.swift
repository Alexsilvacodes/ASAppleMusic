//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import EVReflection

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Playlist.html

enum PlaylistType {
    case userShared
    case editorial
    case external
    case personalMix
}

class Playlist: EVObject {

    var artwork: Artwork?
    var curatorName: String?
    var desc: EditorialNotes?
    var lastModifiedDate: String?
    var name: String?
    var playlistType: PlaylistType?
    var playParams: Playable?
    var url: URL?
    var curator: [Curator]?
    var tracks: [Resource]?

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [(keyInObject: "desc", keyInResource: "description")]
    }
}

