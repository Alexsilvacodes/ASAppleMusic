//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Playable Video object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/playparameters)
 */
public class AMPlayable: Decodable {

    /// (Required) The ID of the content to use for playback.
    public var id: String = ""

    /// (Required) The kind of the content to use for playback.
    public var kind: String = ""

}
