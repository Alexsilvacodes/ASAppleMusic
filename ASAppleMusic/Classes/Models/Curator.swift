//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 Curator object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Curator.html)
 */
public class Curator: EVObject {

    /// The curator artwork
    public var artwork: Artwork?

    /// (Optional) The notes about the curator
    public var editorialNotes: EditorialNotes?

    /// The localized name of the curator
    public var name: String?

    /// The URL for sharing a curator in Apple Music
    public var url: String?
    
    /// The relationships associated with this activity
    public var relationships: [Relationship]?

    /// :nodoc:
    public override func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [
            ("artwork", { if let artwork = $0 as? NSDictionary { self.artwork = Artwork(dictionary: artwork) } }, { return self.artwork }),
            ("editorialNotes", { if let editorialNotes = $0 as? NSDictionary { self.editorialNotes = EditorialNotes(dictionary: editorialNotes) } }, { return self.editorialNotes })
        ]
    }

    func setRelationshipObjects(_ relationships: [String:Any]) {
        var relationshipsArray: [Relationship] = []

        if let playlistsRoot = relationships["playlists"] as? [String:Any],
            let playlistsArray = playlistsRoot["data"] as? [NSDictionary] {

            playlistsArray.forEach { playlist in
                relationshipsArray.append(Relationship(dictionary: playlist))
            }
        }

        if !relationshipsArray.isEmpty {
            self.relationships = relationshipsArray
        }
    }

}

public extension ASAppleMusic {

    /**
     Get Curator based on the id of the `storefront` and the curator `id`

     - Parameters:
     - id: The id of the curator (Number). Example: `"1217688517"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Curator*, *AMError*
     - curator: the `Curator` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/curators/1217688517*
     */
    func getCurator(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ curator: Curator?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/curators/\(id)"
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
                        let curator = Curator(dictionary: attributes)
                        if let relationships = resource["relationships"] as? [String:Any] {
                            curator.setRelationshipObjects(relationships)
                        }
                        completion(curator, nil)
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
     Get several Curator objects based on the `ids` of the curators that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the curators. Example: `["974459448", "1142683517"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[Curator]*, *AMError*
     - curators: the `[Curator]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/curators?ids=974459448,1142683517*
     */
    func getMultipleCurators(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ curators: [Curator]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/curators?ids=\(ids.joined(separator: ","))"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var curators: [Curator]?
                        if resources.count > 0 {
                            curators = []
                        }
                        resources.forEach { curatorData in
                            if let attributes = curatorData["attributes"] as? NSDictionary {
                                let curator = Curator(dictionary: attributes)
                                if let relationships = curatorData["relationships"] as? [String:Any] {
                                    curator.setRelationshipObjects(relationships)
                                }
                                curators?.append(curator)
                            }
                        }
                        completion(curators, nil)
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
