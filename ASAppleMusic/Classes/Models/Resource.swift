//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import EVReflection

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Resourceobject.html

class Resource: EVObject {
    var id: String?
    var href: URL?
    var meta: [String:Any]?
    var type: String?
    var attributes: [String:Any]?
}
