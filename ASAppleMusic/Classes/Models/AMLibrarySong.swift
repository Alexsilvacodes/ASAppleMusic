//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 LibrarySong object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/librarysong)
 */
public class AMLibrarySong: Decodable, AMResource, AMLibraryTrack {

    public class Attributes: Decodable {

        /// The name of the album the song appears on.
        public var albumName: String?

        /// (Required) The artist’s name.
        public var artistName: String = ""

        /// (Required) The album artwork.
        public var artwork: AMArtwork = AMArtwork()

        /// The Recording Industry Association of America (RIAA) rating of the content. The possible values for this rating are clean and explicit. No value means no rating.
        public var contentRating: String?

        /// (Required) The disc number the song appears on.
        public var discNumber: Int = 0

        /// The duration of the song in milliseconds.
        public var durationInMillis: Int64?

        /// (Required) The localized name of the music video.
        public var name: String = ""

        /// The parameters to use to play back the music video.
        public var playParams: AMPlayable?

        /// The number of the music video in the album’s track list.
        public var trackNumber: Int?

    }

    public class Relationships: Decodable {

        /// The albums associated with the song. By default, albums includes identifiers only.
        public var albums: AMRelationship.LibraryAlbum?

        /// The artists associated with the song. By default, artists includes identifiers only.
        public var artists: AMRelationship.LibraryArtist?

    }

    public class Response: Decodable {

        /// The data included in the response for a library song object request.
        public var data: [AMLibrarySong]?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the request that generated the response data or results; not present in a request.
        public var href: String?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

    /// The attributes for the library song.
    public var attributes: Attributes?

    /// The relationships for the library song.
    public var relationships: Relationships?

    // Always librarySongs.
    public var type: String = "librarySongs"

    public enum CodingKeys: String, CodingKey {
        case attributes
        case relationships
        case type
    }

}

public extension ASAppleMusic {

    /**
     Get LibrarySong based on the id of the song `id`

     - Parameters:
     - id: The id of the song (Number). Example: `"900032321"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *LibrarySong*, *AMError*
     - song: the `LibrarySong` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/songs/900032321*
     */
    func getLibrarySong(withID id: String, lang: String? = nil, completion: @escaping (_ song: AMLibrarySong?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/me/library/songs/\(id)"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
            request.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMLibrarySong.Response.self, from: data),
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
                    let response = try? decoder.decode(AMLibrarySong.Response.self, from: data)
                    completion(response?.data?.first, nil)
                } else {
                    completion(nil, nil)
                }
            }
            task.resume()
        }
    }

    /**
     Get several LibrarySong objects based on the `ids` of the songs that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the songs. Example: `["204719240", "203251597"]`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[LibrarySong]*, *AMError*
     - songs: the `[LibrarySong]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/songs?ids=204719240,203251597*
     */
    func getMultipleLibrarySongs(withIDs ids: [String]? = nil, lang: String? = nil, completion: @escaping (_ songs: [AMLibrarySong]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/me/library/songs"
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
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMLibrarySong.Response.self, from: data),
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
                    let response = try? decoder.decode(AMLibrarySong.Response.self, from: data)
                    completion(response?.data, nil)
                } else {
                    completion(nil, nil)
                }
            }
            task.resume()
        }
    }

}
