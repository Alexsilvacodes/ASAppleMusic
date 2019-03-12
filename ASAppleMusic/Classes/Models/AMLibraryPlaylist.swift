//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 LibraryPlaylist object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/libraryplaylist)
 */
public class AMLibraryPlaylist: Codable, AMResource {

    public class Attributes: Codable {

        /// The playlist artwork.
        public var artwork: AMArtwork?

        /// A description of the playlist.
        public var description: String?

        /// (Required) The localized name of the album.
        public var name: String = ""

        /// The parameters to use to play back the tracks in the playlist.
        public var playParams: AMPlayable?

        /// (Required) Indicates whether the playlist can be edited.
        public var canEdit: Bool = false

    }

    public class Relationships: Codable {

        /// The library songs and library music videos included in the playlist. By default, tracks is not included. Only available when fetching a single library playlist resource by ID.
        public var tracks: AMRelationship.LibraryTrack?

    }

    public class Response: Codable {

        /// The data included in the response for a playlist album object request.
        public var data: [AMLibraryPlaylist]?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the request that generated the response data or results; not present in a request.
        public var href: String?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

    /// The attributes for the library playlist.
    public var attributes: Attributes?

    /// The relationships for the library playlist.
    public var relationships: Relationships?

    // Always libraryPlaylists.
    public var type: String = "libraryPlaylists"

}

public extension ASAppleMusic {

    /**
     Get LibraryPlaylist based on the id of the playlist `id`

     - Parameters:
     - id: The id of the playlist. Example: `"pl.acc464d753b94302b8806e6fcde56e17"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *LibraryPlaylist*, *AMError*
     - playlist: the `LibraryPlaylist` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/playlists/pl.acc464d753b94302b8806e6fcde56e17*
     */
    func getLibraryPlaylist(withID id: String, lang: String? = nil, completion: @escaping (_ playlist: AMLibraryPlaylist?, _ error: AMError?) -> Void) {
        callWithToken { devToken, userToken in
            guard let devToken = devToken, let userToken = userToken else {
                let error = AMError()
                error.status = "401"
                error.code = .unauthorized
                error.title = "Unauthorized request"
                error.detail = "Missing token, refresh current token or request a new token"
                completion(nil, error)
                self.print("[ASAppleMusic] 🛑: Missing token")
                return
            }
            var url = "https://api.music.apple.com/v1/me/library/playlists/\(id)"
            if let lang = lang {
                url = url + "?l=\(lang)&include=tracks"
            } else {
                url = url + "?include=tracks"
            }
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
            request.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
            URLSession.init().dataTask(with: request, completionHandler: { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMLibraryPlaylist.Response.self, from: data),
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
                    let response = try? decoder.decode(AMLibraryPlaylist.Response.self, from: data)
                    completion(response?.data?.first, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

    /**
     Get several LibraryPlaylist objects based on the `ids` of the playlists that you want to get

     - Parameters:
     - ids: An id array of the playlists. Example: `["pl.acc464c740b94302b8805e5fcbe67e17", "pl.97c6f95b0b774bedbcce227f9ea5d32b"]`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[LibraryPlaylist]*, *AMError*
     - playlists: the `[LibraryPlaylist]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/playlists?ids=pl.acc464c740b94302b8805e5fcbe67e17,pl.97c6f95b0b774bedbcce227f9ea5d32b*
     */
    func getMultipleLibraryPlaylists(withIDs ids: [String]? = nil, lang: String? = nil, completion: @escaping (_ playlists: [AMLibraryPlaylist]?, _ error: AMError?) -> Void) {
        callWithToken { devToken, userToken in
            guard let devToken = devToken, let userToken = userToken else {
                let error = AMError()
                error.status = "401"
                error.code = .unauthorized
                error.title = "Unauthorized request"
                error.detail = "Missing token, refresh current token or request a new token"
                completion(nil, error)
                self.print("[ASAppleMusic] 🛑: Missing token")
                return
            }
            var url = "https://api.music.apple.com/v1/me/library/playlists"
            if let ids = ids {
                url = url + "?ids=\(ids.joined(separator: ","))&"
            } else {
                url = url + "?"
            }
            if let lang = lang {
                url = url + "l=\(lang)"
            }
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
            request.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
            URLSession.init().dataTask(with: request, completionHandler: { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMLibraryPlaylist.Response.self, from: data),
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
                    let response = try? decoder.decode(AMLibraryPlaylist.Response.self, from: data)
                    completion(response?.data, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

}
