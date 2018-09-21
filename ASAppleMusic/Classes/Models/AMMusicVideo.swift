//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 Music Video object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/musicvideo)
 */
public class AMMusicVideo: EVObject {

    /// The artist’s name
    public var artistName: String?

    /// The artwork for the music video’s associated album
    public var artwork: AMArtwork?

    /// (Optional) The RIAA rating of the content. The possible values for this rating are clean and explicit. No value means no rating
    public var contentRating: Rating?

    /// (Optional) The duration of the music video in milliseconds
    public var durationInMillis: Int64?

    /// (Optional) The editorial notes for the music video
    public var editorialNotes: AMEditorialNotes?

    /// The music video’s associated genres
    public var genreNames: [String]?

    /// The ISRC (International Standard Recording Code) for the music video
    public var isrc: String?

    /// The localized name of the music video
    public var name: String?

    /// (Optional) The parameters to use to playback the music video
    public var playParams: AMPlayable?

    /// The preview assets for the music video
    public var previews: [AMPreview]?

    /// The release date of the music video in YYYY-MM-DD format
    public var releaseDate: String?

    /// (Optional) The number of the music video in the album’s track list
    public var trackNumber: Int?

    /// A clear url directly to the music video
    public var url: String?

    /// (Optional) The video subtype associated with the content
    public var videoSubType: String?

    /// The relationships associated with this activity
    public var relationships: [AMRelationship]?

    /// :nodoc:
    public override func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [
            ("artwork", { if let artwork = $0 as? NSDictionary { self.artwork = AMArtwork(dictionary: artwork) } }, { return self.artwork }),
            ("editorialNotes", { if let editorialNotes = $0 as? NSDictionary { self.editorialNotes = AMEditorialNotes(dictionary: editorialNotes) } }, { return self.editorialNotes }),
            ("playParams", { if let playParams = $0 as? NSDictionary { self.playParams = AMPlayable(dictionary: playParams) } }, { return self.playParams }),
            ("previews", {
                    if let previewsArray = $0 as? [NSDictionary] {
                        var previews: [AMPreview] = []

                        previewsArray.forEach { preview in
                            previews.append(AMPreview(dictionary: preview))
                        }

                        self.previews = previews.isEmpty ? nil : previews
                    }
                }, { return self.previews })
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
        } else if key == "trackNumber" {
            if let rawValue = value as? Int {
                trackNumber = rawValue
            }
        } else if key == "playParams" {
            if let rawValue = value as? NSDictionary {
                playParams = AMPlayable(dictionary: rawValue)
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
        if let genresRoot = relationships["genres"] as? [String:Any],
            let genresArray = genresRoot["data"] as? [NSDictionary] {

            genresArray.forEach { genre in
                relationshipsArray.append(AMRelationship(dictionary: genre))
            }
        }

        if !relationshipsArray.isEmpty {
            self.relationships = relationshipsArray
        }
    }

}

public extension ASAppleMusic {

    /**
     Get Music Video based on the id of the `storefront` and the music video `id`

     - Parameters:
     - id: The id of the music video (Number). Example: `"639322181"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *MusicVideo*, *AMError*
     - musicVideo: the `MusicVideo` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/music-videos/639322181*
     */
    func getMusicVideo(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ musicVideo: AMMusicVideo?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/music-videos/\(id)"
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
                        let musicVideo = AMMusicVideo(dictionary: attributes)
                        if let relationships = resource["relationships"] as? [String:Any] {
                            musicVideo.setRelationshipObjects(relationships)
                        }
                        completion(musicVideo, nil)
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
     Get several Music Video objects based on the `ids` of the music videos that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the music videos. Example: `["609082181", "890853283"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[MusicVideo]*, *AMError*
     - musicVideos: the `[MusicVideo]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/music-videos?ids=609082181,890853283*
     */
    func getMultipleMusicVideos(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ musicVideos: [AMMusicVideo]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/music-videos?ids=\(ids.joined(separator: ","))&"
            if let lang = lang {
                url = url + "l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var musicVideos: [AMMusicVideo]?
                        if resources.count > 0 {
                            musicVideos = []
                        }
                        resources.forEach { musicVideoData in
                            if let attributes = musicVideoData["attributes"] as? NSDictionary {
                                let musicVideo = AMMusicVideo(dictionary: attributes)
                                if let relationships = musicVideoData["relationships"] as? [String:Any] {
                                    musicVideo.setRelationshipObjects(relationships)
                                }
                                musicVideos?.append(musicVideo)
                            }
                        }
                        completion(musicVideos, nil)
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
