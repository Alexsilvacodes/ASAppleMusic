//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Song object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/song)
 */
public class AMSong: Codable, AMResource, AMTrack {

    public class Attributes: Codable {

        /// The name of the album the song appears on.
        public var albumName: String?

        /// (Required) The artist’s name.
        public var artistName: String = ""

        /// (Required) The album artwork.
        public var artwork: AMArtwork = AMArtwork()

        /// The song’s composer.
        public var composerName: String?

        /// The Recording Industry Association of America (RIAA) rating of the content. The possible values for this rating are clean and explicit. No value means no rating.
        public var contentRating: String?

        /// (Required) The disc number the song appears on.
        public var discNumber: Int = 0

        /// The duration of the song in milliseconds.
        public var durationInMillis: Int64?

        /// The editorial notes for the song.
        public var editorialNotes: AMEditorialNotes?

        /// (Required) The music video’s associated genres.
        public var genreNames: [String] = []

        /// (Required) The International Standard Recording Code (ISRC) for the music video.
        public var isrc: String = ""

        /// (Classical music only) The movement count of this song.
        public var movementCount: Int?

        /// (Classical music only) The movement name of this song.
        public var movementName: String?

        /// (Classical music only) The movement number of this song.
        public var movementNumber: Int?

        /// (Required) The localized name of the music video.
        public var name: String = ""

        /// The parameters to use to play back the music video.
        public var playParams: AMPlayable?

        /// (Required) The preview assets for the music video.
        public var previews: [AMPreview] = []

        /// (Required) The release date of the music video in YYYY-MM-DD format.
        public var releaseDate: String = ""

        /// The number of the music video in the album’s track list.
        public var trackNumber: Int?

        // (Required) A URL for sharing the music video.
        public var url: String = ""

        /// (Classical music only) The name of the associated work.
        public var workName: String?

    }

    public class Relationships: Codable {

        /// The albums associated with the song. By default, albums includes identifiers only.
        public var albums: AMRelationship.Album?

        /// The artists associated with the song. By default, artists includes identifiers only.
        public var artists: AMRelationship.Artist?

        /// The genres associated with the song. By default, genres is not included.
        public var genres: AMRelationship.Genre?

        /// The station associated with the song. By default, station is not included.
        public var station: AMRelationship.Station?

    }

    public class Response: Codable {

        /// The data included in the response for a song object request.
        public var data: [AMSong]?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the request that generated the response data or results; not present in a request.
        public var href: String?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

    /// The attributes for the song.
    public var attributes: Attributes?

    /// The relationships for the song.
    public var relationships: Relationships?

    // Always songs.
    public var type: String = "songs"

}

public extension ASAppleMusic {

    /**
     Get Song based on the id of the `storefront` and the song `id`

     - Parameters:
     - id: The id of the song (Number). Example: `"900032321"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Song*, *AMError*
     - song: the `Song` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/songs/900032321*
     */
    func getSong(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ song: AMSong?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/songs/\(id)"
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
                    if let data = data, let response = try? decoder.decode(AMSong.Response.self, from: data),
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
                    let response = try? decoder.decode(AMSong.Response.self, from: data)
                    completion(response?.data?.first, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

    /**
     Get several Song objects based on the `ids` of the songs that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the songs. Example: `["204719240", "203251597"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[Song]*, *AMError*
     - songs: the `[Song]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/songs?ids=204719240,203251597*
     */
    func getMultipleSongs(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ songs: [AMSong]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/songs?ids=\(ids.joined(separator: ","))&"
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
                    if let data = data, let response = try? decoder.decode(AMSong.Response.self, from: data),
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
                    let response = try? decoder.decode(AMSong.Response.self, from: data)
                    completion(response?.data, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

}
