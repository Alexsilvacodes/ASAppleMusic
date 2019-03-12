//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Artwork object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/artwork)
 */
public class AMArtwork: Codable {

    /// (Optional) The average background color of the image
    public var bgColor: String?

    /// The maximum height available for the image
    public var height: Int = 0

    /// The maximum width available for the image
    public var width: Int = 0

    /// (Optional) The primary text color that may be used if the background color is displayed
    public var textColor1: String?

    /// (Optional) The secondary text color that may be used if the background color is displayed
    public var textColor2: String?

    /// (Optional) The tertiary text color that may be used if the background color is displayed
    public var textColor3: String?

    /// (Optional) The final post-tertiary text color that maybe be used if the background color is displayed
    public var textColor4: String?

    /// The URL to request the image asset. The image file name must be preceded by `{w}x{h}, as placeholders for the width and height values described above (for example, `{w}x{h}bb.jpg)
    public var url: String = ""
    
}
