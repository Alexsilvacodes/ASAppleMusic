//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 LibraryMusicVideo object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/librarymusicvideo)
 */
public class AMLibraryMusicVideo: Codable, AMResource, AMLibraryTrack {

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

        /// (Required) The localized name of the music video.
        public var name: String = ""

        /// The parameters to use to play back the music video.
        public var playParams: AMPlayable?

        /// The number of the music video in the album’s track list.
        public var trackNumber: Int?

    }

    public class Relationships: Codable {

        /// The library albums associated with the music video. By default, albums is not included.
        public var albums: AMRelationship.LibraryAlbum?

        /// The library artists associated with the music video. By default, artists is not included.
        public var artists: AMRelationship.LibraryArtist?

    }

    public class Response: Codable {

        /// The data included in the response for a library music video object request.
        public var data: [AMLibraryMusicVideo]?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the request that generated the response data or results; not present in a request.
        public var href: String?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

    /// The attributes for the library music video.
    public var attributes: Attributes?

    /// The relationships for the library music video.
    public var relationships: Relationships?

    // Always libraryMusicVideos.
    public var type: String = "libraryMusicVideos"

}

public extension ASAppleMusic {

    /**
     Get LibraryMusicVideo based on the music video `id`

     - Parameters:
     - id: The id of the music video (Number). Example: `"639322181"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *LibraryMusicVideo*, *AMError*
     - musicVideo: the `LibraryMusicVideo` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/music-videos/639322181*
     */
    func getLibraryMusicVideo(withID id: String, lang: String? = nil, completion: @escaping (_ musicVideo: AMLibraryMusicVideo?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/me/library/music-videos/\(id)"
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
            URLSession.init().dataTask(with: request, completionHandler: { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMLibraryMusicVideo.Response.self, from: data),
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
                    let response = try? decoder.decode(AMLibraryMusicVideo.Response.self, from: data)
                    completion(response?.data?.first, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

    /**
     Get several LibraryMusicVideo objects based on the `ids` of the music videos that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: (Optional) An id array of the music videos. Example: `["609082181", "890853283"]`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[LibraryMusicVideo]*, *AMError*
     - musicVideos: the `[LibraryMusicVideo]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/music-videos?ids=609082181,890853283*
     */
    func getMultipleLibraryMusicVideos(withIDs ids: [String]? = nil, lang: String? = nil, completion: @escaping (_ musicVideos: [AMLibraryMusicVideo]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/me/library/music-videos"
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
                    if let data = data, let response = try? decoder.decode(AMLibraryMusicVideo.Response.self, from: data),
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
                    let response = try? decoder.decode(AMLibraryMusicVideo.Response.self, from: data)
                    completion(response?.data, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

}
