//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 LibraryMusicVideo object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/librarymusicvideo)
 */
public class AMLibraryMusicVideo: EVObject {

    /// The name of the album the music video appears on
    public var albumName: String?

    /// The artist’s name
    public var artistName: String?

    /// The artwork for the music video’s associated album
    public var artwork: AMArtwork?

    /// (Optional) The RIAA rating of the content. The possible values for this rating are clean and explicit. No value means no rating
    public var contentRating: Rating?

    /// (Optional) The duration of the music video in milliseconds
    public var durationInMillis: Int64?

    /// The localized name of the music video
    public var name: String?

    /// (Optional) The parameters to use to playback the music video
    public var playParams: AMPlayable?

    /// (Optional) The number of the music video in the album’s track list
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

        if !relationshipsArray.isEmpty {
            self.relationships = relationshipsArray
        }
    }

}

public extension ASAppleMusic {

    /**
     Get LibraryMusicVideo based on the music video `id`

     - Parameters:
     - id: The id of the music video (Number). Example: `"639322181"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *LibraryMusicVideo*, *AMError*
     - musicVideo: the `LibraryMusicVideo` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/music-videos/639322181*
     */
    func getLibraryMusicVideo(withID id: String, lang: String? = nil, completion: @escaping (_ musicVideo: AMLibraryMusicVideo?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/me/library/music-videos/\(id)"
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
                        let musicVideo = AMLibraryMusicVideo(dictionary: attributes)
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
     Get several LibraryMusicVideo objects based on the `ids` of the music videos that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: (Optional) An id array of the music videos. Example: `["609082181", "890853283"]`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[LibraryMusicVideo]*, *AMError*
     - musicVideos: the `[LibraryMusicVideo]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/music-videos?ids=609082181,890853283*
     */
    func getMultipleLibraryMusicVideos(withIDs ids: [String]? = nil, lang: String? = nil, completion: @escaping (_ musicVideos: [AMLibraryMusicVideo]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/me/library/music-videos"
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
                        var musicVideos: [AMLibraryMusicVideo]?
                        if resources.count > 0 {
                            musicVideos = []
                        }
                        resources.forEach { musicVideoData in
                            if let attributes = musicVideoData["attributes"] as? NSDictionary {
                                let musicVideo = AMLibraryMusicVideo(dictionary: attributes)
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
