//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/RelationshipDictionary.html

protocol Relationship {

    var data: [Any] { get set }
    var href: URL { get set }
    var meta: [String: Any] { get set }
    var next: URL { get set }
}
