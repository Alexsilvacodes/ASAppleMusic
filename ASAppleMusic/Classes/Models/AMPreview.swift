//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Playlist Type object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/preview)
 */
public class AMPreview: Decodable {

    /// The ID of the content to use for playback
    public var url: String = ""

    /// The kind of the content to use for playback
    public var artwork: AMArtwork?

}
