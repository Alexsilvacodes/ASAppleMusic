//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Artist object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/artist)
 */
public class AMArtist: Codable, AMResource {

    public class Attributes: Codable {

        /// The notes about the activity that appear in the iTunes Store.
        public var editorialNotes: AMEditorialNotes?

        /// (Required) The names of the genres associated with this artist.
        public var genreNames: [String] = []

        /// (Required) The localized name of the artist.
        public var name: String = ""

        /// (Required) The URL for sharing an artist in the iTunes Store.
        public var url: String = ""

    }

    public class Relationships: Codable {

        /// The albums associated with the artist. By default, albums includes identifiers only.
        public var albums: AMRelationship.Album?

        /// The genres associated with the artist. By default, genres is not included.
        public var genres: AMRelationship.Genre?

        /// The music videos associated with the artist. By default, musicVideos is not included.
        public var musicVideos: AMRelationship.MusicVideo?

        /// The playlists associated with the artist. By default, playlists is not included.
        public var playlists: AMRelationship.Playlist?

        /// The station associated with the artist. By default, station is not included.
        public var station: AMRelationship.Station?

    }

    public class Response: Codable {

        /// The data included in the response to an artist object request.
        public var data: [AMArtist]?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the request that generated the response data or results; not present in a request.
        public var href: String?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

    /// The attributes for the artist.
    public var attributes: Attributes?

    /// The relationships for the artist.
    public var relationships: Relationships?

    // Always artists.
    public var type: String = "artists"

}

public extension ASAppleMusic {

    /**
     Get Artist based on the id of the `storefront` and the artist `id`

     - Parameters:
     - id: The id of the artist (Number). Example: `"179934"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Artist*, *AMError*
     - artist: the `Artist` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/artists/179934*
     */
    func getArtist(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ artist: AMArtist?, _ error: AMError?) -> Void) {
        callWithToken { token in
            guard let token = token else {
                let error = AMError()
                error.status = "401"
                error.code = .unauthorized
                error.title = "Unauthorized request"
                error.detail = "Missing token, refresh current token or request a new token"
                completion(nil, error)
                self.self.print("[ASAppleMusic] 🛑: Missing token")
                return
            }
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/artists/\(id)"
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
            URLSession.init().dataTask(with: request, completionHandler: { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMArtist.Response.self, from: data),
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
                    let response = try? decoder.decode(AMArtist.Response.self, from: data)
                    completion(response?.data?.first, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

    /**
     Get several Artist objects based on the `ids` of the artists that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the artists. Example: `["179934", "463106"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[Artist]*, *AMError*
     - artists: the `[Artist]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/artists?ids=179934,463106*
     */
    func getMultipleArtists(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ artists: [AMArtist]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/artists?ids=\(ids.joined(separator: ","))&"
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
            URLSession.init().dataTask(with: request, completionHandler: { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMArtist.Response.self, from: data),
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
                    let response = try? decoder.decode(AMArtist.Response.self, from: data)
                    completion(response?.data, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

}
