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

    /// The maximum width available for the image
    public var width: Int?

    /// The maximum height available for the image
    public var height: Int?

    /// The URL to request the image asset. The image file name must be preceded by `{w}x{h}, as placeholders for the width and height values described above (for example, `{w}x{h}bb.jpg)
    public var url: String?

    /// (Optional) The average background color of the image
    public var bgColor: String?

    /// (Optional) The primary text color that may be used if the background color is displayed
    public var textColor1: String?

    /// (Optional) The secondary text color that may be used if the background color is displayed
    public var textColor2: String?

    /// (Optional) The tertiary text color that may be used if the background color is displayed
    public var textColor3: String?

    /// (Optional) The final post-tertiary text color that maybe be used if the background color is displayed
    public var textColor4: String?

    /// :nodoc:
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
