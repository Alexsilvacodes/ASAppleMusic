//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import EVReflection

/**
 Artwork object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Artwork.html)
 */
public class Artwork: EVObject {

    public var width: Int?
    public var height: Int?
    public var url: String?
    public var bgColor: String?
    public var textColor1: String?
    public var textColor2: String?
    public var textColor3: String?
    public var textColor4: String?

    public override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "width" {
            if let rawValue = value as? Int {
                width = rawValue
            }
        } else if key == "height" {
            if let rawValue = value as? Int {
                height = rawValue
            }
        }
    }
    
}
