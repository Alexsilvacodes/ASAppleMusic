//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import EVReflection

public enum RelationshipType: String {
    case activities = "activities"
    case albums = "albums"
    case appleCurator = "apple-curator"
    case artists = "artists"
    case curators = "curators"
    case genres = "genres"
    case playlists = "playlists"
    case stations = "stations"
}

/**
 Relationship object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/RelationshipDictionary.html)
 */
public class Relationship: EVObject {

    public var id: String?
    public var href: String?
    public var type: RelationshipType?

    public override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "type" {
            if let rawValue = value as? String, let relationship = RelationshipType(rawValue: rawValue) {
                type = relationship
            }
        }
    }

}
