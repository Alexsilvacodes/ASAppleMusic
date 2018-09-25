//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 Artist object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/artist)
 */
public class AMArtist: EVObject {

    /// The names of the genres associated with this artist
    public var genreNames: [String]?

    /// (Optional) The notes about the artist that appear in the iTunes Store
    public var editorialNotes: AMEditorialNotes?

    /// The localized name of the artist
    public var name: String?

    /// The URL for sharing an artist in the iTunes Store
    public var url: String?

    /// The relationships associated with this activity
    public var relationships: [AMRelationship]?

    /// The music videos on the album
    public var musicVideos: [AMMusicVideo]?

    /// :nodoc:
    public override func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [
            ("editorialNotes", { if let editorialNotes = $0 as? NSDictionary { self.editorialNotes = AMEditorialNotes(dictionary: editorialNotes) } }, { return self.editorialNotes })
        ]
    }

    func setRelationshipObjects(_ relationships: [String:Any]) {
        var relationshipsArray: [AMRelationship] = []

        if let albumsRoot = relationships["albums"] as? [String:Any],
            let albumsArray = albumsRoot["data"] as? [NSDictionary] {

            albumsArray.forEach { album in
                relationshipsArray.append(AMRelationship(dictionary: album))
            }
        }
        if let genresRoot = relationships["genres"] as? [String:Any],
            let genresArray = genresRoot["data"] as? [NSDictionary] {

            genresArray.forEach { genre in
                relationshipsArray.append(AMRelationship(dictionary: genre))
            }
        }
        if let musicVideosRoot = relationships["music-videos"] as? [String:Any],
            let musicVideosArray = musicVideosRoot["data"] as? [[String:Any]] {
            var musicVideos: [AMMusicVideo] = []

            musicVideosArray.forEach { musicVideoData in
                if let musicVideo = musicVideoData["attributes"] as? NSDictionary {
                    musicVideos.append(AMMusicVideo(dictionary: musicVideo))
                }
            }

            self.musicVideos = musicVideos
        }
        if let playlistsRoot = relationships["playlists"] as? [String:Any],
            let playlistsArray = playlistsRoot["data"] as? [NSDictionary] {

            playlistsArray.forEach { playlist in
                relationshipsArray.append(AMRelationship(dictionary: playlist))
            }
        }

        if !relationshipsArray.isEmpty {
            self.relationships = relationshipsArray
        }
    }

}

public extension ASAppleMusic {

    /**
     Get Artist based on the id of the `storefront` and the artist `id`

     - Parameters:
     - id: The id of the artist (Number). Example: `"179934"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Artist*, *AMError*
     - artist: the `Artist` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/artists/179934*
     */
    func getArtist(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ artist: AMArtist?, _ error: AMError?) -> Void) {
        callWithToken { token in
            guard let token = token else {
                let error = AMError()
                error.status = "401"
                error.code = .unauthorized
                error.title = "Unauthorized request"
                error.detail = "Missing token, refresh current token or request a new token"
                completion(nil, error)
                self.self.print("[ASAppleMusic] 🛑: Missing token")
                return
            }
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/artists/\(id)"
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
                        let artist = AMArtist(dictionary: attributes)
                        if let relationships = resource["relationships"] as? [String:Any] {
                            artist.setRelationshipObjects(relationships)
                        }
                        completion(artist, nil)
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
     Get several Artist objects based on the `ids` of the artists that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the artists. Example: `["179934", "463106"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[Artist]*, *AMError*
     - artists: the `[Artist]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/artists?ids=179934,463106*
     */
    func getMultipleArtists(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ artists: [AMArtist]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/artists?ids=\(ids.joined(separator: ","))&"
            if let lang = lang {
                url = url + "l=\(lang)"
            }
            Alamofire.SessionManager.default.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var artists: [AMArtist]?
                        if resources.count > 0 {
                            artists = []
                        }
                        resources.forEach { artistData in
                            if let attributes = artistData["attributes"] as? NSDictionary {
                                let artist = AMArtist(dictionary: attributes)
                                if let relationships = artistData["relationships"] as? [String:Any] {
                                    artist.setRelationshipObjects(relationships)
                                }
                                artists?.append(artist)
                            }
                        }
                        completion(artists, nil)
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
