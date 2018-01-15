//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 Song object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Song.html)
 */
public class Song: EVObject {

    public var artistName: String?
    public var artwork: Artwork?
    public var composerName: String?
    public var contentRating: Rating?
    public var discNumber: Int?
    public var durationInMillis: Int64?
    public var editorialNotes: EditorialNotes?
    public var genreNames: [String]?
    public var isrc: String?
    public var movementCount: Int?
    public var movementName: String?
    public var movementNumber: Int?
    public var name: String?
    public var playParams: Playable?
    public var previews: [Preview]?
    public var releaseDate: String?
    public var trackNumber: Int?
    public var url: String?
    public var workName: String?
    public var albums: [Album]?
    public var artists: [Artist]?
    public var genres: [Genre]?

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
        } else if key == "movementCount" {
            if let rawValue = value as? Int {
                movementCount = rawValue
            }
        } else if key == "movementNumber" {
            if let rawValue = value as? Int {
                movementNumber = rawValue
            }
        } else if key == "trackNumber" {
            if let rawValue = value as? Int {
                trackNumber = rawValue
            }
        }
    }

    func setRelationships(_ relationships: [String:Any]) {
        if let albumsRoot = relationships["albums"] as? [String:Any],
            let albumsArray = albumsRoot["data"] as? [NSDictionary] {
            var albums: [Album] = []

            albumsArray.forEach { album in
                albums.append(Album(dictionary: album))
            }

            self.albums = albums
        }
        if let artistsRoot = relationships["artists"] as? [String:Any],
            let artistsArray = artistsRoot["data"] as? [NSDictionary] {
            var artists: [Artist] = []

            artistsArray.forEach { artist in
                artists.append(Artist(dictionary: artist))
            }

            self.artists = artists
        }
        if let genresRoot = relationships["genres"] as? [String:Any],
            let genresArray = genresRoot["data"] as? [NSDictionary] {
            var genres: [Genre] = []

            genresArray.forEach { genre in
                genres.append(Genre(dictionary: genre))
            }

            self.genres = genres
        }
    }

}

public extension ASAppleMusic {

    /**
     Get Song based on the id of the `storefront` and the song `id`

     - Parameters:
     - id: The id of the song (Number). Example: `"900032321"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Song*, *AMError*
     - song: the `Song` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/songs/900032321*
     */
    func getSong(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ song: Song?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/songs/\(id)"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    if let response = response.result.value as? [String:Any],
                        let data = response["data"] as? [[String:Any]],
                        let resource = data.first,
                        let attributes = resource["attributes"] as? NSDictionary {
                        let song = Song(dictionary: attributes)
                        if let relationships = resource["relationships"] as? [String:Any] {
                            song.setRelationships(relationships)
                        }
                        completion(song, nil)
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
     Get several Song objects based on the `ids` of the songs that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the songs. Example: `["204719240", "203251597"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Song*, *AMError*
     - songs: the `[Song]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/songs?ids=204719240,203251597*
     */
    func getMultipleSongs(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ songs: [Song]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/songs?ids=\(ids.joined(separator: ","))"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var songs: [Song]?
                        if resources.count > 0 {
                            songs = []
                        }
                        resources.forEach { songData in
                            if let attributes = songData["attributes"] as? NSDictionary {
                                let song = Song(dictionary: attributes)
                                if let relationships = songData["relationships"] as? [String:Any] {
                                    song.setRelationships(relationships)
                                }
                                songs?.append(song)
                            }
                        }
                        completion(songs, nil)
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
