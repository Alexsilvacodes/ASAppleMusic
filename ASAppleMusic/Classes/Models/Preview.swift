//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import EVReflection

/**
 Playlist Type object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Preview.html)
 */
public class Preview: EVObject {

    /// The ID of the content to use for playback
    public var url: String?

    /// The kind of the content to use for playback
    public var artwork: Artwork?

    /// :nodoc:
    public override func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [
            ("artwork", { if let artwork = $0 as? NSDictionary { self.artwork = Artwork(dictionary: artwork) } }, { return self.artwork })
        ]
    }

}
