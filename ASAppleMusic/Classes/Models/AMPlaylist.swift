//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Playlist Type object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/playlist)
 */
public enum AMPlaylistType: String, Codable {
    case userShared = "user-shared"
    case editorial = "editorial"
    case external = "external"
    case personalMix = "personal-mix"
}

/**
 Playlist object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/playlist)
 */
public class AMPlaylist: Codable, AMResource {

    public class Attributes: Codable {

        /// The playlist artwork.
        public var artwork: AMArtwork?

        /// The display name of the curator.
        public var curatorName: String?

        /// A description of the playlist.
        public var description: AMEditorialNotes?

        /// (Required) The date the playlist was last modified.
        public var lastModifiedDate: String = ""

        /// (Required) The localized name of the album.
        public var name: String = ""

        /// The parameters to use to play back the tracks in the playlist.
        public var playParams: AMPlayable?

        /// (Required) The type of playlist. Possible values are:
        /// user-shared: A playlist created and shared by an Apple Music user.
        /// editorial: A playlist created by an Apple Music curator.
        /// external: A playlist created by a non-Apple curator or brand.
        /// personal-mix: A personalized playlist for an Apple Music user.
        /// Possible values: user-shared, editorial, external, personal-mix
        public var playlistType: AMPlaylistType = .editorial

        /// (Required) The URL for sharing an album in the iTunes Store.
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

        /// The data included in the response to an playlist object request.
        public var data: [AMPlaylist]?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the request that generated the response data or results; not present in a request.
        public var href: String?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

    /// The attributes for the playlist.
    public var attributes: Attributes?

    /// The relationships for the playlist.
    public var relationships: Relationships?

    // Always playlists.
    public var type: String = "playlists"

}

public extension ASAppleMusic {

    /**
     Get Playlist based on the id of the `storefront` and the playlist `id`

     - Parameters:
     - id: The id of the playlist. Example: `"pl.acc464d753b94302b8806e6fcde56e17"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Playlist*, *AMError*
     - playlist: the `Playlist` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/playlists/pl.acc464d753b94302b8806e6fcde56e17*
     */
    func getPlaylist(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ playlist: AMPlaylist?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/playlists/\(id)"
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
                    if let data = data, let response = try? decoder.decode(AMPlaylist.Response.self, from: data),
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
                    let response = try? decoder.decode(AMPlaylist.Response.self, from: data)
                    completion(response?.data?.first, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

    /**
     Get several Playlist objects based on the `ids` of the playlists that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the playlists. Example: `["pl.acc464c740b94302b8805e5fcbe67e17", "pl.97c6f95b0b774bedbcce227f9ea5d32b"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[Playlist]*, *AMError*
     - playlists: the `[Playlist]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/playlists?ids=pl.acc464c740b94302b8805e5fcbe67e17,pl.97c6f95b0b774bedbcce227f9ea5d32b*
     */
    func getMultiplePlaylists(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ playlists: [AMPlaylist]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/playlists?ids=\(ids.joined(separator: ","))&"
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
                    if let data = data, let response = try? decoder.decode(AMPlaylist.Response.self, from: data),
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
                    let response = try? decoder.decode(AMPlaylist.Response.self, from: data)
                    completion(response?.data, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

}
