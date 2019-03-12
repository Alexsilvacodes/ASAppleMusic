//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 EditorialNotes object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/editorialnotes)
 */
public class AMEditorialNotes: Codable {

    /// Notes shown when the content is being prominently displayed
    public var standard: String = ""

    /// Abbreviated notes shown in-line or when the content is shown alongside other content
    public var short: String = ""

}
