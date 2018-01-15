//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 Album object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Album.html)
 */
public class Album: EVObject {

    public var artistName: String?
    public var artwork: Artwork?
    public var contentRating: String?
    public var copyright: String?
    public var editorialNotes: EditorialNotes?
    public var genreNames: [String]?
    public var isComplete: Bool?
    public var isSingle: Bool?
    public var name: String?
    public var recordLabel: String?
    public var releaseDate: String?
    public var playParams: Playable?
    public var trackCount: Int?
    public var url: String?
    public var artists: [Artist]?
    public var genres: [Genre]?
    public var songs: [Song]?
    public var musicVideos: [MusicVideo]?

    public override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "trackCount" {
            if let rawValue = value as? Int {
                trackCount = rawValue
            }
        }
    }

    func setRelationships(_ relationships: [String:Any]) {
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
    func getAlbum(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ album: Album?, _ error: AMError?) -> Void) {
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
                    if let response = response.result.value as? [String:Any],
                        let data = response["data"] as? [[String:Any]],
                        let resource = data.first,
                        let attributes = resource["attributes"] as? NSDictionary {
                        let album = Album(dictionary: attributes)
                        if let relationships = resource["relationships"] as? [String:Any] {
                            album.setRelationships(relationships)
                        }
                        completion(album, nil)
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
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Album*, *AMError*
     - albums: the `[Album]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/albums?ids=299738314,190758912*
     */
    func getMultipleAlbums(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ albums: [Album]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/albums?ids=\(ids.joined(separator: ","))"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var albums: [Album]?
                        if resources.count > 0 {
                            albums = []
                        }
                        resources.forEach { albumData in
                            if let attributes = albumData["attributes"] as? NSDictionary {
                                let album = Album(dictionary: attributes)
                                if let relationships = albumData["relationships"] as? [String:Any] {
                                    album.setRelationships(relationships)
                                }
                                albums?.append(album)
                            }
                        }
                        completion(albums, nil)
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
