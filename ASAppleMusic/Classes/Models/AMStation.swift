//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Station object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/station)
 */
public class AMStation: Decodable, AMResource {

    public class Attributes: Decodable {

        /// (Required) The radio station artwork
        public var artwork: AMArtwork = AMArtwork()

        /// The duration of the stream. This value is not emitted for 'live' or programmed stations.
        public var durationInMillis: Int64?

        /// The notes about the curator that appear in the iTunes Store
        public var editorialNotes: AMEditorialNotes?

        /// The episode number of the station. This value is emitted when the station represents an episode of a show or other content.
        public var episodeNumber: Int?

        /// (Required) Whether the station is a live stream.
        public var isLive: Bool = false

        /// (Required) The localized name of the curator
        public var name: String = ""

        /// (Required) The URL for sharing an curator in the iTunes Store
        public var url: String = ""

    }

    public class Response: Decodable {

        /// (Required) The data included in the response for a station object request.
        public var data: [AMStation]?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the request that generated the response data or results; not present in a request.
        public var href: String?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

    /// The attributes for the station.
    public var attributes: Attributes?

    // Always stations.
    public var type: String = "stations"

    public var description: String {
        get {
            return "attributes: \(attributes.debugDescription)"
        }
    }

    public enum CodingKeys: String, CodingKey {
        case attributes
        case type
    }

}

public extension ASAppleMusic {

    /**
     Get Station based on the id of the `storefront` and the station `id`

     - Parameters:
     - id: The id of the station (Number). Example: `"ra.925434166"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Station*, *AMError*
     - station: the `Station` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/stations/ra.925434166*
     */
    func getStation(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ station: AMStation?, _ error: AMError?) -> Void) {
        callWithToken { token in
            guard let token = token else {
                let error = AMError()
                error.status = "401"
                error.code = .unauthorized
                error.title = "Unauthorized request"
                error.detail = "Missing token, refresh current token or request a new token"
                completion(nil, error)
                self.print("[ASAppleMusic] 🛑: Missing token")
                return
            }
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/stations/\(id)"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMStation.Response.self, from: data),
                        let amError = response.errors?.first {
                        completion(nil, amError)
                    } else {
                        let amError = AMError()
                        if let response = response, let statusCode = response.getStatusCode(),
                            let code = Code(rawValue: String(statusCode * 100)) {
                            amError.status = String(statusCode)
                            amError.code = code
                        }
                        amError.detail = error.localizedDescription
                        completion(nil, amError)
                    }
                } else if let data = data {
                    self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    let response = try? decoder.decode(AMStation.Response.self, from: data)
                    completion(response?.data?.first, nil)
                } else {
                    completion(nil, nil)
                }
            }
            task.resume()
        }
    }

    /**
     Get several Station objects based on the `ids` of the stations that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the stations. Example: `["ra.925344166", "ra.1228162316"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[Station]*, *AMError*
     - stations: the `[Station]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/stations?ids=ra.925344166,ra.1228162316*
     */
    func getMultipleStations(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ stations: [AMStation]?, _ error: AMError?) -> Void) {
        callWithToken { token in
            guard let token = token else {
                let error = AMError()
                error.status = "401"
                error.code = .unauthorized
                error.title = "Unauthorized request"
                error.detail = "Missing token, refresh current token or request a new token"
                completion(nil, error)
                self.print("[ASAppleMusic] 🛑: Missing token")
                return
            }
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/stations?ids=\(ids.joined(separator: ","))&"
            if let lang = lang {
                url = url + "l=\(lang)"
            }
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMStation.Response.self, from: data),
                        let amError = response.errors?.first {
                        completion(nil, amError)
                    } else {
                        let amError = AMError()
                        if let response = response, let statusCode = response.getStatusCode(),
                            let code = Code(rawValue: String(statusCode * 100)) {
                            amError.status = String(statusCode)
                            amError.code = code
                        }
                        amError.detail = error.localizedDescription
                        completion(nil, amError)
                    }
                } else if let data = data {
                    self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    let response = try? decoder.decode(AMStation.Response.self, from: data)
                    completion(response?.data, nil)
                } else {
                    completion(nil, nil)
                }
            }
            task.resume()
        }
    }

}

