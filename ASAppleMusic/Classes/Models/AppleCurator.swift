//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 Apple Curator object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/AppleCurator.html)
 */
public class AppleCurator: EVObject {

    public var artwork: Artwork?
    public var editorialNotes: EditorialNotes?
    public var name: String?
    public var url: String?
    public var playlists: [Playlist]?

    func setRelationships(_ relationships: [String:Any]) {
        if let playlistsRoot = relationships["playlists"] as? [String:Any],
            let playlistsArray = playlistsRoot["data"] as? [NSDictionary] {
            var playlists: [Playlist] = []

            playlistsArray.forEach { playlist in
                playlists.append(Playlist(dictionary: playlist))
            }

            self.playlists = playlists
        }
    }

}

public extension ASAppleMusic {

    /**
     Get AppleCurator based on the id of the `storefront` and the apple curator `id`

     - Parameters:
     - id: The id of the apple curator (Number). Example: `"926449586"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *AppleCurator*, *AMError*
     - appleCurator: the `AppleCurator` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/apple-curators/926449586*
     */
    func getAppleCurator(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ appleCurator: AppleCurator?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/apple-curators/\(id)"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    if let response = response.result.value as? [String:Any],
                        let data = response["data"] as? [[String:Any]],
                        let resource = data.first,
                        let attributes = resource["attributes"] as? NSDictionary {
                        let appleCurator = AppleCurator(dictionary: attributes)
                        if let relationships = resource["relationships"] as? [String:Any] {
                            appleCurator.setRelationships(relationships)
                        }
                        completion(appleCurator, nil)
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
     Get several AppleCurator objects based on the `ids` of the appleCurators that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the appleCurators. Example: `["974459448", "1142683517"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *AppleCurator*, *AMError*
     - appleCurators: the `[AppleCurator]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/apple-curators?ids=974459448,1142683517*
     */
    func getMultipleAppleCurators(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ appleCurators: [AppleCurator]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/apple-curators?ids=\(ids.joined(separator: ","))"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var appleCurators: [AppleCurator]?
                        if resources.count > 0 {
                            appleCurators = []
                        }
                        resources.forEach { appleCuratorData in
                            if let attributes = appleCuratorData["attributes"] as? NSDictionary {
                                let appleCurator = AppleCurator(dictionary: attributes)
                                if let relationships = appleCuratorData["relationships"] as? [String:Any] {
                                    appleCurator.setRelationships(relationships)
                                }
                                appleCurators?.append(appleCurator)
                            }
                        }
                        completion(appleCurators, nil)
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
