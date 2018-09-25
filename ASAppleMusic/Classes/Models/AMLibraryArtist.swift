//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 LibraryArtist object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/libraryartist)
 */
public class AMLibraryArtist: EVObject {

    /// The localized name of the artist
    public var name: String?

    /// The relationships associated with this activity
    public var relationships: [AMRelationship]?

    func setRelationshipObjects(_ relationships: [String:Any]) {
        var relationshipsArray: [AMRelationship] = []

        if let albumsRoot = relationships["albums"] as? [String:Any],
            let albumsArray = albumsRoot["data"] as? [NSDictionary] {

            albumsArray.forEach { album in
                relationshipsArray.append(AMRelationship(dictionary: album))
            }
        }

        if !relationshipsArray.isEmpty {
            self.relationships = relationshipsArray
        }
    }

}

public extension ASAppleMusic {

    /**
     Get LibraryArtist based on the id of the `storefront` and the artist `id`

     - Parameters:
     - id: The id of the artist (Number). Example: `"179934"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *LibraryArtist*, *AMError*
     - artist: the `LibraryArtist` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/artists/179934*
     */
    func getLibraryArtist(withID id: String, lang: String? = nil, completion: @escaping (_ artist: AMLibraryArtist?, _ error: AMError?) -> Void) {
        callWithToken { devToken, userToken in
            guard let devToken = devToken, let userToken = userToken else {
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
                "Authorization": "Bearer \(devToken)",
                "Music-User-Token": userToken
            ]
            var url = "https://api.music.apple.com/v1/me/library/artists/\(id)"
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
                        let artist = AMLibraryArtist(dictionary: attributes)
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
     Get several LibraryArtist objects based on the `ids` of the artists that you want to get

     - Parameters:
     - ids: (Optional) An id array of the artists. Example: `["179934", "463106"]`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[LibraryArtist]*, *AMError*
     - artists: the `[LibraryArtist]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/artists?ids=179934,463106*
     */
    func getMultipleLibraryArtists(withIDs ids: [String]? = nil, lang: String? = nil, completion: @escaping (_ artists: [AMLibraryArtist]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/me/library/artists"
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
                        var artists: [AMLibraryArtist]?
                        if resources.count > 0 {
                            artists = []
                        }
                        resources.forEach { artistData in
                            if let attributes = artistData["attributes"] as? NSDictionary {
                                let artist = AMLibraryArtist(dictionary: attributes)
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
