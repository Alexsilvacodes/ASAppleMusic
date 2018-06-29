//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import EVReflection

/**
 Playable Video object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/PlayParameters.html)
 */
public class AMPlayable: EVObject {

    /// Notes shown when the content is being prominently displayed
    public var id: String?

    /// Abbreviated notes shown in-line or when the content is shown alongside other content
    public var kind: String?

}
