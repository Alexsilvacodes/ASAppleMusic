//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Music Video object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/musicvideo)
 */
public class AMMusicVideo: Codable, AMResource, AMTrack {

    public class Attributes: Codable {

        /// The name of the album the music video appears on.
        public var albumName: String?

        /// (Required) The artist’s name.
        public var artistName: String = ""

        /// (Required) The artwork for the music video’s associated album.
        public var artwork: AMArtwork = AMArtwork()

        /// The Recording Industry Association of America (RIAA) rating of the content. The possible values for this rating are clean and explicit. No value means no rating.
        public var contentRating: String?

        /// The duration of the music video in milliseconds.
        public var durationInMillis: Int64?

        /// The editorial notes for the music video.
        public var editorialNotes: AMEditorialNotes?

        /// (Required) The music video’s associated genres.
        public var genreNames: [String] = []

        /// (Required) The International Standard Recording Code (ISRC) for the music video.
        public var isrc: String = ""

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

        /// The video subtype associated with the content.
        public var videoSubType: String?

        /// (Required) Whether the music video has HDR10-encoded content.
        public var hasHDR: Bool = false

        /// (Required) Whether the music video has 4K content.
        public var has4K: Bool = false

    }

    public class Relationships: Codable {

        /// The curators associated with the playlist. By default, curator includes identifiers only.
        public var curator: AMRelationship.Curator?

        /// The tracks associated with the playlist. By default, tracks includes identifiers only.
        public var tracks: AMRelationship.Track?

    }

    public class Response: Codable {

        /// The data included in the response for a music video object request.
        public var data: [AMMusicVideo]?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the request that generated the response data or results; not present in a request.
        public var href: String?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

    /// The attributes for the music video.
    public var attributes: Attributes?

    /// The relationships for the music video.
    public var relationships: Relationships?

    // Always musicVideos.
    public var type: String = "musicVideos"

}

public extension ASAppleMusic {

    /**
     Get Music Video based on the id of the `storefront` and the music video `id`

     - Parameters:
     - id: The id of the music video (Number). Example: `"639322181"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *MusicVideo*, *AMError*
     - musicVideo: the `MusicVideo` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/music-videos/639322181*
     */
    func getMusicVideo(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ musicVideo: AMMusicVideo?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/music-videos/\(id)"
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
                    if let data = data, let response = try? decoder.decode(AMMusicVideo.Response.self, from: data),
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
                    let response = try? decoder.decode(AMMusicVideo.Response.self, from: data)
                    completion(response?.data?.first, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

    /**
     Get several Music Video objects based on the `ids` of the music videos that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the music videos. Example: `["609082181", "890853283"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[MusicVideo]*, *AMError*
     - musicVideos: the `[MusicVideo]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/music-videos?ids=609082181,890853283*
     */
    func getMultipleMusicVideos(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ musicVideos: [AMMusicVideo]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/music-videos?ids=\(ids.joined(separator: ","))&"
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
                    if let data = data, let response = try? decoder.decode(AMMusicVideo.Response.self, from: data),
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
                    let response = try? decoder.decode(AMMusicVideo.Response.self, from: data)
                    completion(response?.data, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

}
