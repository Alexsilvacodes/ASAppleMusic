//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 Lbrary Album object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/libraryalbum/)
 */
public class AMLibraryAlbum: EVObject {

    /// The artist’s name
    public var artistName: String?

    /// The album artwork
    public var artwork: AMArtwork?

    /// (Optional) The RIAA rating of the content. The possible values for this rating are clean and explicit. No value means no rating
    public var contentRating: String?

    /// The localized name of the album
    public var name: String?

    /// (Optional) The parameters to use to playback the tracks of the album
    public var playParams: AMPlayable?

    /// The URL for to reference an album in your library
    public var url: URL?

    /// The number of tracks.
    public var trackCount: Int?

    /// The songs included in the playlist
    public var songs: [AMLibrarySong]?

    /// The relationships associated with this activity
    public var relationships: [AMRelationship]?

    /// :nodoc:
    public override func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [
            ("artwork", { if let artwork = $0 as? NSDictionary { self.artwork = AMArtwork(dictionary: artwork) } }, { return self.artwork }),
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
        if let tracksRoot = relationships["tracks"] as? [String:Any],
            let tracks = tracksRoot["data"] as? [[String:Any]] {
            var songs: [AMLibrarySong] = []

            tracks.forEach { track in
                if let type = track["type"] as? String,
                    type == "library-songs" {
                    if let attributes = track["attributes"] as? NSDictionary {
                        let song = AMLibrarySong(dictionary: attributes)
                        songs.append(song)
                    }
                }
            }

            if !songs.isEmpty {
                self.songs = songs
            }
        }
    }

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
            let headers = [
                "Authorization": "Bearer \(devToken)",
                "Music-User-Token": userToken
            ]
            var url = "https://api.music.apple.com/v1/me/library/albums/\(id)"
            if let lang = lang {
                url = url + "?l=\(lang)&include=tracks"
            } else {
                url = url + "?include=tracks"
            }
            Alamofire.SessionManager.default.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let data = response["data"] as? [[String:Any]],
                        let resource = data.first,
                        let href = resource["href"] as? String,
                        let attributes = resource["attributes"] as? NSDictionary {
                        let album = AMLibraryAlbum(dictionary: attributes)
                        album.url = URL(string: "https://api.music.apple.com\(href)")
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
            let headers = [
                "Authorization": "Bearer \(devToken)",
                "Music-User-Token": userToken
            ]
            var url = "https://api.music.apple.com/v1/me/library/albums"
            if let ids = ids {
                url = url + "?ids=\(ids.joined(separator: ","))&"
            } else {
                url = url + "?"
            }
            if let lang = lang {
                url = url + "l=\(lang)"
            }
            Alamofire.SessionManager.default.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var albums: [AMLibraryAlbum]?
                        if resources.count > 0 {
                            albums = []
                        }
                        resources.forEach { albumData in
                            if let attributes = albumData["attributes"] as? NSDictionary,
                                let href = albumData["href"] as? String {
                                let album = AMLibraryAlbum(dictionary: attributes)
                                album.url = URL(string: "https://api.music.apple.com\(href)")
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
