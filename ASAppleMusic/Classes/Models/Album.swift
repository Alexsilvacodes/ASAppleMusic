//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 Album object represntation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Album.html)
 */

public class Album: EVObject {

    var artistName: String?
    var artwork: Artwork?
    var contentRating: String?
    var copyright: String?
    var editorialNotes: EditorialNotes?
    var genreNames: [String]?
    var isComplete: Bool?
    var isSingle: Bool?
    var name: String?
    var recordLabel: String?
    var releaseDate: String?
    var playParams: Playable?
    var trackCount: Int?
    var url: URL?
    var playlists: [Playlist]?
    var genres: [Genre]?
    var tracks: [Resource]?
}

public extension ASAppleMusic {

    /**
     Get Album based on the id of the `storefront` and the album `id`

     - Parameters:
     - id: The id of the store in two-letter code. Example: `"us"`
     - lang: The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Storefront*, *Error*
     - storefront: the `Storefront` object itself
     - error: if the request you will get an `Error` object

     **Example:** *https://api.music.apple.com/v1/storefronts/us*
     */
    func getStorefront(withID id: String, lang: String? = nil, completion: @escaping (_ storefront: Storefront?, _ error: AMError?) -> Void) {
        callWithToken { token in
            guard let token = token else {
                completion(nil, AMError())
                return
            }
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            var url = "https://api.music.apple.com/v1/storefronts/\(id)"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    if let response = response.result.value as? [String:Any],
                        let data = response["data"] as? [[String:Any]],
                        let resource = data.first,
                        let attributes = resource["attributes"] as? NSDictionary {
                        let storefront = Storefront(dictionary: attributes)
                        completion(storefront, nil)
                    } else {
                        completion(nil, AMError())
                    }
            }
        }
    }

    /**
     Get several Storefront objects based on the `ids` of the stores that you want to get

     - Parameters:
     - ids: An id array of the stores in two-letter code. Example: `["us", "es", "jp"]`
     - lang: The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Storefront*, *Error*
     - storefront: the `Storefront` object itself
     - error: if the request you will get an `Error` object

     **Example:** *https://api.music.apple.com/v1/storefronts?ids=us,es,jp*
     */
    func getMultipleStorefronts(withIDs ids: [String], lang: String? = nil, completion: @escaping (_ storefront: [Storefront]?, _ error: AMError?) -> Void) {
        callWithToken { token in
            guard let token = token else {
                completion(nil, AMError())
                return
            }
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            var url = "https://api.music.apple.com/v1/storefronts/\(ids.joined(separator: ","))"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var storefronts: [Storefront]?
                        if resources.count > 0 {
                            storefronts = []
                        }
                        resources.forEach { storefrontData in
                            if let attributes = storefrontData["attributes"] as? NSDictionary {
                                storefronts?.append(Storefront(dictionary: attributes))
                            }
                        }
                        completion(storefronts, nil)
                    } else {
                        completion(nil, AMError())
                    }
            }
        }
    }

}
