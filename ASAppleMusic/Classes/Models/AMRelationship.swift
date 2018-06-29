//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import EVReflection

public enum AMRelationshipType: String {

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
public class AMRelationship: EVObject {

    /// One or more destination objects
    public var id: String?

    /// A URL subpath that fetches the resource as the primary object. This member is only present in responses
    public var href: String?

    /// Type of the relationship, take a look at the enum to know the types
    public var type: AMRelationshipType?

    /// :nodoc:
    public override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "type" {
            if let rawValue = value as? String, let relationship = AMRelationshipType(rawValue: rawValue) {
                type = relationship
            }
        }
    }

}
