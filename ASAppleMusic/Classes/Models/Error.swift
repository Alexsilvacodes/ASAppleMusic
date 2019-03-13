//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Code object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/HTTPStatusCodes.html)
 */
public enum Code: String, Decodable {

    case ok = "20000"
    case created = "20100"
    case accepted = "20200"
    case noContent = "20400"
    case movedPermanently = "30100"
    case found = "30200"
    case badRequest = "40000"
    case unauthorized = "40100"
    case forbidden = "40300"
    case notFound = "40400"
    case methodNotAllowed = "40500"
    case conflict = "40900"
    case payloadTooLarge = "41300"
    case URITooLong = "41400"
    case tooManyRequests = "42900"
    case internalServerError = "50000"
    case notImplemented = "50100"
    case serviceUnavailable = "50300"

}

/**
 Error object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/error)
 */
public class AMError: Decodable {

    /**
     Source object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/error/source)
     */
    public class Source: Decodable {

        /// The URI query parameter that caused the error
        public var parameter: String?

    }

    /// The code for this error. For possible values, [see HTTP Status Codes](https://developer.apple.com/documentation/applemusicapi/http_status_codes)
    public var code: Code = .notFound

    /// A long description of the problem that may be localized
    public var detail: String?

    /// A unique identifier for this occurrence of the error
    public var id: String = "Unknown"

    /// A object containing references to the source of the error. For possible members, [see Source object](https://developer.apple.com/documentation/applemusicapi/error/source)
    public var source: Source?

    /// The HTTP status code for this problem
    public var status: String = "404"

    /// A short description of the problem that may be localized
    public var title: String = "Resource Not Found"

}
