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

    /// The URI query parameter that caused the error
    public var parameter: String?

}

/**
 Error object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/ErrorDictionary.html)
 */
public class AMError: EVObject {

    /// A unique identifier for this occurrence of the error
    public var id: String?

    /// A link to more information about this occurrence
    public var about: String?

    /// The HTTP status code for this problem
    public var status: String?

    /// The code for this error. For possible values, [see HTTP Status Codes](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/HTTPStatusCodes.html)
    public var code: Code?

    /// A short description of the problem that may be localized
    public var title: String?

    /// A long description of the problem that may be localized
    public var detail: String?

    /// A object containing references to the source of the error. For possible members, [see Source object](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/ErrorDictionary.html)
    public var source: Source?

    /// Contains meta information about the error
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
