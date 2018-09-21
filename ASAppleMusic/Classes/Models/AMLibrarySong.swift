//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 LibrarySong object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/librarysong)
 */
public class AMLibrarySong: EVObject {

    /// The name of the album the song appears on
    public var albumName: String?

    /// The artist’s name
    public var artistName: String?

    /// The album artwork
    public var artwork: AMArtwork?

    /// (Optional) The RIAA rating of the content. The possible values for this rating are clean and explicit. No value means no rating
    public var contentRating: Rating?

    /// The disc number the song appears on
    public var discNumber: Int?

    /// (Optional) The duration of the song in milliseconds
    public var durationInMillis: Int64?

    /// The localized name of the song
    public var name: String?

    /// (Optional) The parameters to use to playback the song
    public var playParams: AMPlayable?

    /// The number of the song in the album’s track list
    public var trackNumber: Int?

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
        if key == "contentRating" {
            if let rawValue = value as? String {
                contentRating = Rating(rawValue: rawValue)
            }
        } else if key == "durationInMillis" {
            if let rawValue = value as? Int64 {
                durationInMillis = rawValue
            }
        } else if key == "discNumber" {
            if let rawValue = value as? Int {
                discNumber = rawValue
            }
        } else if key == "trackNumber" {
            if let rawValue = value as? Int {
                trackNumber = rawValue
            }
        }
    }

    func setRelationshipObjects(_ relationships: [String:Any]) {
        var relationshipsArray: [AMRelationship] = []

        if let albumsRoot = relationships["albums"] as? [String:Any],
            let albumsArray = albumsRoot["data"] as? [NSDictionary] {

            albumsArray.forEach { album in
                relationshipsArray.append(AMRelationship(dictionary: album))
            }
        }
        if let artistsRoot = relationships["artists"] as? [String:Any],
            let artistsArray = artistsRoot["data"] as? [NSDictionary] {

            artistsArray.forEach { artist in
                relationshipsArray.append(AMRelationship(dictionary: artist))
            }
        }

        if !relationshipsArray.isEmpty {
            self.relationships = relationshipsArray
        }
    }

}

public extension ASAppleMusic {

    /**
     Get LibrarySong based on the id of the song `id`

     - Parameters:
     - id: The id of the song (Number). Example: `"900032321"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *LibrarySong*, *AMError*
     - song: the `LibrarySong` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/songs/900032321*
     */
    func getLibrarySong(withID id: String, lang: String? = nil, completion: @escaping (_ song: AMLibrarySong?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/me/library/songs/\(id)"
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
                        let song = AMLibrarySong(dictionary: attributes)
                        if let relationships = resource["relationships"] as? [String:Any] {
                            song.setRelationshipObjects(relationships)
                        }
                        completion(song, nil)
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
     Get several LibrarySong objects based on the `ids` of the songs that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the songs. Example: `["204719240", "203251597"]`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[LibrarySong]*, *AMError*
     - songs: the `[LibrarySong]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/songs?ids=204719240,203251597*
     */
    func getMultipleLibrarySongs(withIDs ids: [String]? = nil, lang: String? = nil, completion: @escaping (_ songs: [AMLibrarySong]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/me/library/songs"
            if let ids = ids {
                url = url + "?ids=\(ids.joined(separator: ","))&"
            } else {
                url = url + "?"
            }
            if let lang = lang {
                url = url + "l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var songs: [AMLibrarySong]?
                        if resources.count > 0 {
                            songs = []
                        }
                        resources.forEach { songData in
                            if let attributes = songData["attributes"] as? NSDictionary {
                                let song = AMLibrarySong(dictionary: attributes)
                                if let relationships = songData["relationships"] as? [String:Any] {
                                    song.setRelationshipObjects(relationships)
                                }
                                songs?.append(song)
                            }
                        }
                        completion(songs, nil)
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
