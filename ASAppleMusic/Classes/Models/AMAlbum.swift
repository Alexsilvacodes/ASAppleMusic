//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Album object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/album)
 */
public class AMAlbum: Codable, AMResource {

    public class Attributes: Codable {

        /// (Required) The name of the album the music video appears on.
        public var albumName: String = ""

        /// (Required) The artist’s name.
        public var artistName: String = ""

        /// The album artwork.
        public var artwork: AMArtwork?

        /// The Recording Industry Association of America (RIAA) rating of the content. The possible values for this rating are clean and explicit. No value means no rating.
        public var contentRating: String?

        /// The copyright text.
        public var copyright: String?

        /// The notes about the album that appear in the iTunes Store.
        public var editorialNotes: AMEditorialNotes?

        /// (Required) The names of the genres associated with this album.
        public var genreNames: [String] = []

        /// (Required) Indicates whether the album is complete. If true, the album is complete; otherwise, it is not. An album is complete if it contains all its tracks and songs.
        public var isComplete: Bool = false

        /// (Required) Indicates whether the album contains a single song.
        public var isSingle: Bool = false

        /// (Required) The localized name of the album.
        public var name: String = ""

        /// The parameters to use to play back the tracks of the album.
        public var playParams: AMPlayable?

        /// (Required) The name of the record label for the album.
        public var recordLabel: String = ""

        /// (Required) The release date of the album in YYYY-MM-DD format.
        public var releaseDate: String = ""

        /// (Required) The number of tracks.
        public var trackCount: Int = 0

        /// (Required) The URL for sharing the album in the iTunes Store.
        public var url: String = ""

        /// (Required) Indicates whether the album has been delivered as Mastered for iTunes.
        public var isMasteredForItunes: Bool = false

    }

    public class Relationships: Codable {

        /// The artists associated with the album. By default, artists includes identifiers only.
        public var artists: AMRelationship.Artist?

        /// The genres for the album. By default, genres is not included.
        public var genres: AMRelationship.Genre?

        /// The songs and music videos on the album. By default, tracks includes objects.
        public var tracks: AMRelationship.Track?

    }

    public class Response: Codable {

        /// The data included in the response to an album object request.
        public var data: [AMAlbum]?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the request that generated the response data or results; not present in a request.
        public var href: String?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

    /// The attributes for the album.
    public var attributes: Attributes?

    /// The relationships for the album.
    public var relationships: Relationships?

    // Always albums.
    public var type: String = "albums"
    
}

public extension ASAppleMusic {

    /**
     Get Album based on the id of the `storefront` and the album `id`

     - Parameters:
     - id: The id of the album (Number). Example: `"190758912"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Album*, *AMError*
     - album: the `Album` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/albums/190758912*
     */
    func getAlbum(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ album: AMAlbum?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/albums/\(id)"
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
                    if let data = data, let response = try? decoder.decode(AMAlbum.Response.self, from: data),
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
                    let response = try? decoder.decode(AMAlbum.Response.self, from: data)
                    completion(response?.data?.first, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

    /**
     Get several Album objects based on the `ids` of the albums that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the albums. Example: `["299738314", "190758912"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[Album]*, *AMError*
     - albums: the `[Album]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/albums?ids=299738314,190758912*
     */
    func getMultipleAlbums(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ albums: [AMAlbum]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/albums?ids=\(ids.joined(separator: ","))&"
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
                    if let data = data, let response = try? decoder.decode(AMAlbum.Response.self, from: data),
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
                    let response = try? decoder.decode(AMAlbum.Response.self, from: data)
                    completion(response?.data, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

}
