//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Lbrary Album object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/libraryalbum/)
 */
public class AMLibraryAlbum: Codable, AMResource {

    public class Attributes: Codable {

        /// (Required) The artist’s name.
        public var artistName: String = ""

        /// The album artwork.
        public var artwork: AMArtwork?

        /// The Recording Industry Association of America (RIAA) rating of the content. The possible values for this rating are clean and explicit. No value means no rating.
        public var contentRating: String?

        /// (Required) The localized name of the album.
        public var name: String = ""

        /// The parameters to use to play back the tracks of the album.
        public var playParams: AMPlayable?

        /// (Required) The number of tracks.
        public var trackCount: Int = 0

    }

    public class Relationships: Codable {

        /// The library artists associated with the album. By default, artists includes identifiers only.
        public var artists: AMRelationship.LibraryArtist?

        /// The library songs and library music videos on the album. By default, tracks includes objects.
        public var tracks: AMRelationship.LibraryTrack?

    }

    public class Response: Codable {

        /// The data included in the response for a library album object request.
        public var data: [AMLibraryAlbum]?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the request that generated the response data or results; not present in a request.
        public var href: String?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

    /// The attributes for the library album.
    public var attributes: Attributes?

    /// The relationships for the library album.
    public var relationships: Relationships?

    // Always libraryAlbums.
    public var type: String = "libraryAlbums"

}

public extension ASAppleMusic {

    /**
     Get LibraryAlbum based on the id of the album

     - Parameters:
     - id: The id of the album (Number). Example: `"190758912"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *LibraryAlbum*, *AMError*
     - album: the `LibraryAlbum` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/albums/190758912*
     */
    func getLibraryAlbum(withID id: String, lang: String? = nil, completion: @escaping (_ album: AMLibraryAlbum?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/me/library/albums/\(id)"
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
                    if let data = data, let response = try? decoder.decode(AMLibraryAlbum.Response.self, from: data),
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
                    let response = try? decoder.decode(AMLibraryAlbum.Response.self, from: data)
                    completion(response?.data?.first, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

    /**
     Get several LibraryAlbum objects based on the `ids` of the albums

     - Parameters:
     - ids: (Optional) An id array of the albums. Example: `["299738314", "190758912"]`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[LibraryAlbum]*, *AMError*
     - albums: the `[LibraryAlbum]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/albums?ids=299738314,190758912*
     */
    func getMultipleLibraryAlbums(withIDs ids: [String]? = nil, lang: String? = nil, completion: @escaping (_ albums: [AMLibraryAlbum]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/me/library/albums"
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
                    if let data = data, let response = try? decoder.decode(AMLibraryAlbum.Response.self, from: data),
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
                    let response = try? decoder.decode(AMLibraryAlbum.Response.self, from: data)
                    completion(response?.data, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

}
