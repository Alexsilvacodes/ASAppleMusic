//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import EVReflection

/**
 Code object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/HTTPStatusCodes.html)
 */
public enum Code: Int {

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
    case internalServerError = 500
    case notImplemented = 501
    case serviceUnavailable = 503

}

/**
 Source object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/ErrorDictionary.html)
 */
public class Source: EVObject {
    public var parameter: String?
}

/**
 Error object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Error.html)
 */
public class AMError: EVObject {

    public var id: String?
    public var about: String?
    public var status: String?
    public var code: Code?
    public var title: String?
    public var detail: String?
    public var source: Source?
    public var meta: [String: Any]?
    /// :nodoc:
    public override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "code" {
            if let rawValue = value as? String {
                let indexEnd = rawValue.index(rawValue.startIndex, offsetBy: 3)
                let rawValueSub = String(rawValue[..<indexEnd])

                if let rawInt = Int(rawValueSub) {
                    code = Code(rawValue: rawInt)
                }
            }
        }
    }

}
