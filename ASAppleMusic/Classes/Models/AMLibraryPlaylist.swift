//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 LibraryPlaylist object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/libraryplaylist)
 */
public class AMLibraryPlaylist: EVObject {

    /// (Optional) The playlist artwork
    public var artwork: AMArtwork?

    /// (Optional) A description of the playlist
    public var desc: AMEditorialNotes?

    /// The localized name of the album
    public var name: String?

    /// (Optional) The parameters to use to playback the tracks in the playlist
    public var playParams: AMPlayable?

    /// The URL for to reference a playlist in your library
    public var url: URL?

    /// Indicates whether the playlist can be edited
    public var canEdit: Bool?

    /// The songs included in the playlist
    public var songs: [AMLibrarySong]?

    /// The relationships associated with this activity
    public var relationships: [AMRelationship]?

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
            let headers = [
                "Authorization": "Bearer \(devToken)",
                "Music-User-Token": userToken
            ]
            var url = "https://api.music.apple.com/v1/me/library/playlists/\(id)"
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
                        let playlist = AMLibraryPlaylist(dictionary: attributes)
                        playlist.url = URL(string: "https://api.music.apple.com\(href)")
                        if let relationships = resource["relationships"] as? [String:Any] {
                            playlist.setRelationshipObjects(relationships)
                        }
                        completion(playlist, nil)
                        self.print(playlist)
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
            let headers = [
                "Authorization": "Bearer \(devToken)",
                "Music-User-Token": userToken
            ]
            var url = "https://api.music.apple.com/v1/me/library/playlists"
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
                        var playlists: [AMLibraryPlaylist]?
                        if resources.count > 0 {
                            playlists = []
                        }
                        resources.forEach { playlistData in
                            if let attributes = playlistData["attributes"] as? NSDictionary,
                                let href = playlistData["href"] as? String {
                                let playlist = AMLibraryPlaylist(dictionary: attributes)
                                playlist.url = URL(string: "https://api.music.apple.com\(href)")
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
