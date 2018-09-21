//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 Album object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/album)
 */
public class AMAlbum: EVObject {

    /// The artist’s name
    public var artistName: String?

    /// The album artwork
    public var artwork: AMArtwork?

    /// (Optional) The RIAA rating of the content. The possible values for this rating are clean and explicit. No value means no rating
    public var contentRating: String?

    /// The copyright text
    public var copyright: String?

    /// (Optional) The notes about the album that appear in the iTunes Store
    public var editorialNotes: AMEditorialNotes?

    /// The names of the genres associated with this album
    public var genreNames: [String]?

    /// Indicates whether the album is complete. If true, the album is complete; otherwise, it is not. An album is complete if it contains all its tracks and songs
    public var isComplete: Bool?

    /// Indicates whether the album contains a single song
    public var isSingle: Bool?

    /// The localized name of the album
    public var name: String?

    /// The localized name of the album
    public var recordLabel: String?

    /// The release date of the album in YYYY-MM-DD format
    public var releaseDate: String?

    /// (Optional) The parameters to use to playback the tracks of the album
    public var playParams: AMPlayable?

    /// The number of tracks.
    public var trackCount: Int?

    /// The URL for sharing an album in the iTunes Store
    public var url: String?

    /// The relationships associated with this activity
    public var relationships: [AMRelationship]?

    /// The songs on the album
    public var songs: [AMSong]?

    /// The music videos on the album
    public var musicVideos: [AMMusicVideo]?

    /// :nodoc:
    public override func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [
            ("artwork", { if let artwork = $0 as? NSDictionary { self.artwork = AMArtwork(dictionary: artwork) } }, { return self.artwork }),
            ("editorialNotes", { if let editorialNotes = $0 as? NSDictionary { self.editorialNotes = AMEditorialNotes(dictionary: editorialNotes) } }, { return self.editorialNotes }),
            ("playParams", { if let playParams = $0 as? NSDictionary { self.playParams = AMPlayable(dictionary: playParams) } }, { return self.playParams })
        ]
    }

    /// :nodoc:
    public override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "trackCount" {
            if let rawValue = value as? Int {
                trackCount = rawValue
            }
        }
    }

    func setRelationshipObjects(_ relationships: [String:Any]) {
        var relationshipsArray: [AMRelationship] = []

        if let artistsRoot = relationships["artists"] as? [String:Any],
            let artistsArray = artistsRoot["data"] as? [NSDictionary] {

            artistsArray.forEach { artist in
                relationshipsArray.append(AMRelationship(dictionary: artist))
            }
        }
        if let genresRoot = relationships["genres"] as? [String:Any],
            let genresArray = genresRoot["data"] as? [NSDictionary] {

            genresArray.forEach { genre in
                relationshipsArray.append(AMRelationship(dictionary: genre))
            }
        }
        if let tracksRoot = relationships["tracks"] as? [String:Any],
            let tracks = tracksRoot["data"] as? [[String:Any]] {
            var songs: [AMSong] = []
            var musicVideos: [AMMusicVideo] = []

            tracks.forEach { track in
                if let type = track["type"] as? String,
                    let trackType = TrackType(rawValue: type) {
                    switch trackType {
                    case .songs:
                        if let attributes = track["attributes"] as? NSDictionary {
                            let song = AMSong(dictionary: attributes)
                            songs.append(song)
                        }
                    case .musicVideos:
                        if let attributes = track["attributes"] as? NSDictionary {
                            let musicVideo = AMMusicVideo(dictionary: attributes)
                            musicVideos.append(musicVideo)
                        }
                    }
                }
            }

            if !songs.isEmpty {
                self.songs = songs
            }
            if !musicVideos.isEmpty {
                self.musicVideos = musicVideos
            }
        }

        if !relationshipsArray.isEmpty {
            self.relationships = relationshipsArray
        }
    }
    
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
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/albums/\(id)"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let data = response["data"] as? [[String:Any]],
                        let resource = data.first,
                        let attributes = resource["attributes"] as? NSDictionary {
                        let album = AMAlbum(dictionary: attributes)
                        if let relationships = resource["relationships"] as? [String:Any] {
                            album.setRelationshipObjects(relationships)
                        }
                        completion(album, nil)
                        self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    } else if let response = response.result.value as? [String:Any],
                        let errors = response["errors"] as? [[String:Any]],
                        let errorDict = errors.first as NSDictionary? {
                        let error = AMError(dictionary: errorDict)

                        self.print("[ASAppleMusic] 🛑: \(error.title ?? "") - \(error.status ?? "")")

                        completion(nil, error)
                    } else {
                        self.print("[ASAppleMusic] 🛑: Unauthorized request")

                        let error = AMError()
                        error.status = "401"
                        error.code = .unauthorized
                        error.title = "Unauthorized request"
                        error.detail = "Missing token, refresh current token or request a new token"
                        completion(nil, error)
                    }
            }
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
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/albums?ids=\(ids.joined(separator: ","))&"
            if let lang = lang {
                url = url + "l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var albums: [AMAlbum]?
                        if resources.count > 0 {
                            albums = []
                        }
                        resources.forEach { albumData in
                            if let attributes = albumData["attributes"] as? NSDictionary {
                                let album = AMAlbum(dictionary: attributes)
                                if let relationships = albumData["relationships"] as? [String:Any] {
                                    album.setRelationshipObjects(relationships)
                                }
                                albums?.append(album)
                            }
                        }
                        completion(albums, nil)
                        self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    } else if let response = response.result.value as? [String:Any],
                        let errors = response["errors"] as? [[String:Any]],
                        let errorDict = errors.first as NSDictionary? {
                        let error = AMError(dictionary: errorDict)

                        self.print("[ASAppleMusic] 🛑: \(error.title ?? "") - \(error.status ?? "")")

                        completion(nil, error)
                    } else {
                        self.print("[ASAppleMusic] 🛑: Unauthorized request")

                        let error = AMError()
                        error.status = "401"
                        error.code = .unauthorized
                        error.title = "Unauthorized request"
                        error.detail = "Missing token, refresh current token or request a new token"
                        completion(nil, error)
                    }
            }
        }
    }

}
