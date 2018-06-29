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
public class AMAppleCurator: EVObject {

    /// The curator artwork
    public var artwork: AMArtwork?

    /// (Optional) The notes about the curator that appear in the iTunes Store
    public var editorialNotes: AMEditorialNotes?

    /// The localized name of the curator
    public var name: String?

    /// The URL for sharing an curator in the iTunes Store
    public var url: String?

    /// The relationships associated with this activity
    public var relationships: [AMRelationship]?

    /// :nodoc:
    public override func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [
            ("artwork", { if let artwork = $0 as? NSDictionary { self.artwork = AMArtwork(dictionary: artwork) } }, { return self.artwork }),
            ("editorialNotes", { if let editorialNotes = $0 as? NSDictionary { self.editorialNotes = AMEditorialNotes(dictionary: editorialNotes) } }, { return self.editorialNotes })
        ]
    }

    func setRelationshipObjects(_ relationships: [String:Any]) {
        var relationshipsArray: [AMRelationship] = []

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
    func getAppleCurator(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ appleCurator: AMAppleCurator?, _ error: AMError?) -> Void) {
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
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let data = response["data"] as? [[String:Any]],
                        let resource = data.first,
                        let attributes = resource["attributes"] as? NSDictionary {
                        let appleCurator = AMAppleCurator(dictionary: attributes)
                        if let relationships = resource["relationships"] as? [String:Any] {
                            appleCurator.setRelationshipObjects(relationships)
                        }
                        completion(appleCurator, nil)
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
     Get several AppleCurator objects based on the `ids` of the appleCurators that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the appleCurators. Example: `["974459448", "1142683517"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[AppleCurator]*, *AMError*
     - appleCurators: the `[AppleCurator]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/apple-curators?ids=974459448,1142683517*
     */
    func getMultipleAppleCurators(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ appleCurators: [AMAppleCurator]?, _ error: AMError?) -> Void) {
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
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var appleCurators: [AMAppleCurator]?
                        if resources.count > 0 {
                            appleCurators = []
                        }
                        resources.forEach { appleCuratorData in
                            if let attributes = appleCuratorData["attributes"] as? NSDictionary {
                                let appleCurator = AMAppleCurator(dictionary: attributes)
                                if let relationships = appleCuratorData["relationships"] as? [String:Any] {
                                    appleCurator.setRelationshipObjects(relationships)
                                }
                                appleCurators?.append(appleCurator)
                            }
                        }
                        completion(appleCurators, nil)
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
