//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 Playlist Type object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Playlist.html)
 */
public enum PlaylistType: String {
    case userShared = "user-shared"
    case editorial = "editorial"
    case external = "external"
    case personalMix = "personal-mix"
}

/**
 Playlist object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Playlist.html)
 */
public class Playlist: EVObject {

    public var artwork: Artwork?
    public var curatorName: String?
    public var desc: EditorialNotes?
    public var lastModifiedDate: String?
    public var name: String?
    public var playlistType: PlaylistType?
    public var playParams: Playable?
    public var url: String?
    public var curators: [Curator]?
    public var songs: [Song]?
    public var musicVideos: [MusicVideo]?

    public override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return [(keyInObject: "desc", keyInResource: "description")]
    }

    public override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "playlistType" {
            if let rawValue = value as? String {
                playlistType = PlaylistType(rawValue: rawValue)
            }
        }
    }

    func setRelationships(_ relationships: [String:Any]) {
        if let curatorsRoot = relationships["curator"] as? [String:Any],
            let curatorsArray = curatorsRoot["data"] as? [NSDictionary] {
            var curators: [Curator] = []

            curatorsArray.forEach { curator in
                curators.append(Curator(dictionary: curator))
            }

            self.curators = curators
        }
        if let tracksRoot = relationships["tracks"] as? [String:Any],
            let tracks = tracksRoot["data"] as? [[String:Any]] {
            var songs: [Song] = []
            var musicVideos: [MusicVideo] = []

            tracks.forEach { track in
                if let type = track["type"] as? String,
                    let trackType = TrackType(rawValue: type) {
                    switch trackType {
                    case .songs:
                        if let attributes = track["attributes"] as? NSDictionary {
                            let song = Song(dictionary: attributes)
                            songs.append(song)
                        }
                    case .musicVideos:
                        if let attributes = track["attributes"] as? NSDictionary {
                            let musicVideo = MusicVideo(dictionary: attributes)
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
    func getPlaylist(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ playlist: Playlist?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/playlist/\(id)"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    if let response = response.result.value as? [String:Any],
                        let data = response["data"] as? [[String:Any]],
                        let resource = data.first,
                        let attributes = resource["attributes"] as? NSDictionary {
                        let playlist = Playlist(dictionary: attributes)
                        if let relationships = resource["relationships"] as? [String:Any] {
                            playlist.setRelationships(relationships)
                        }
                        completion(playlist, nil)
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
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Playlist*, *AMError*
     - playlists: the `[Playlist]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/playlists?ids=pl.acc464c740b94302b8805e5fcbe67e17,pl.97c6f95b0b774bedbcce227f9ea5d32b*
     */
    func getMultiplePlaylists(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ playlists: [Playlist]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/playlists?ids=\(ids.joined(separator: ","))"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var playlists: [Playlist]?
                        if resources.count > 0 {
                            playlists = []
                        }
                        resources.forEach { playlistData in
                            if let attributes = playlistData["attributes"] as? NSDictionary {
                                let playlist = Playlist(dictionary: attributes)
                                if let relationships = playlistData["relationships"] as? [String:Any] {
                                    playlist.setRelationships(relationships)
                                }
                                playlists?.append(playlist)
                            }
                        }
                        completion(playlists, nil)
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
