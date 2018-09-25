//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 Playlist Type object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/playlist)
 */
public enum AMPlaylistType: String {
    case userShared = "user-shared"
    case editorial = "editorial"
    case external = "external"
    case personalMix = "personal-mix"
}

/**
 Playlist object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/playlist)
 */
public class AMPlaylist: EVObject {

    /// (Optional) The playlist artwork
    public var artwork: AMArtwork?

    /// (Optional) The display name of the curator
    public var curatorName: String?

    /// (Optional) A description of the playlist
    public var desc: AMEditorialNotes?

    /// The date the playlist was last modified
    public var lastModifiedDate: String?

    /// The localized name of the album
    public var name: String?

    /// The type of playlist
    public var playlistType: AMPlaylistType?

    /// (Optional) The parameters to use to playback the tracks in the playlist
    public var playParams: AMPlayable?

    /// The URL for sharing an album in the iTunes Store
    public var url: String?

    /// The relationships associated with this activity
    public var relationships: [AMRelationship]?

    /// The songs included in the playlist
    public var songs: [AMSong]?

    /// The music videos included in the playlist
    public var musicVideos: [AMMusicVideo]?

    /// :nodoc:
    public override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [(keyInObject: "desc", keyInResource: "description")]
    }

    /// :nodoc:
    public override func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [
            ("artwork", { if let artwork = $0 as? NSDictionary { self.artwork = AMArtwork(dictionary: artwork) } }, { return self.artwork }),
            ("desc", { if let description = $0 as? NSDictionary { self.desc = AMEditorialNotes(dictionary: description) } }, { return self.desc }),
            ("playParams", { if let playParams = $0 as? NSDictionary { self.playParams = AMPlayable(dictionary: playParams) } }, { return self.playParams })
        ]
    }

    /// :nodoc:
    public override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "playlistType" {
            if let rawValue = value as? String {
                playlistType = AMPlaylistType(rawValue: rawValue)
            }
        }
    }

    func setRelationshipObjects(_ relationships: [String:Any]) {
        var relationshipsArray: [AMRelationship] = []

        if let curatorsRoot = relationships["curators"] as? [String:Any],
            let curatorsArray = curatorsRoot["data"] as? [NSDictionary] {

            curatorsArray.forEach { curator in
                relationshipsArray.append(AMRelationship(dictionary: curator))
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
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/playlists/\(id)"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.SessionManager.default.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let data = response["data"] as? [[String:Any]],
                        let resource = data.first,
                        let attributes = resource["attributes"] as? NSDictionary {
                        let playlist = AMPlaylist(dictionary: attributes)
                        if let relationships = resource["relationships"] as? [String:Any] {
                            playlist.setRelationshipObjects(relationships)
                        }
                        completion(playlist, nil)
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
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/playlists?ids=\(ids.joined(separator: ","))&"
            if let lang = lang {
                url = url + "l=\(lang)"
            }
            Alamofire.SessionManager.default.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var playlists: [AMPlaylist]?
                        if resources.count > 0 {
                            playlists = []
                        }
                        resources.forEach { playlistData in
                            if let attributes = playlistData["attributes"] as? NSDictionary {
                                let playlist = AMPlaylist(dictionary: attributes)
                                if let relationships = playlistData["relationships"] as? [String:Any] {
                                    playlist.setRelationshipObjects(relationships)
                                }
                                playlists?.append(playlist)
                            }
                        }
                        completion(playlists, nil)
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
