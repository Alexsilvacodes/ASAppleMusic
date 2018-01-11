//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import EVReflection

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/HTTPStatusCodes.html

enum Code: Int {

    case ok = 200
    case created = 201
    case accepted = 202
    case noContent = 204
    case movedPermanently = 301
    case found = 302
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case conflict = 409
    case payloadTooLarge = 413
    case URITooLong = 414
    case tooManyRequests = 429
    case notImplemented = 501
    case serviceUnavailable = 503

}

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/ErrorDictionary.html

class Source: EVObject {
    var parameter: String?
}

public class Error: EVObject {

    var id: String?
    var about: String?
    var status: String?
    var code: Code?
    var title: String?
    var detail: String?
    var source: Source?
    var meta: [String: Any]?
}
