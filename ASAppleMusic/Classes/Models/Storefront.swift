//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Storefront.html

public class Storefront: EVObject {

    public var name: String?
    var storefrontId: Int?
    var supportedLanguageTags: [String]?
    var defaultLanguageTag: String?
}

public extension ASAppleMusic {

    func getStorefront(withID id: String, lang: String? = nil, completion: @escaping (_ storefront: Storefront?, _ error: Error?) -> Void) {
        callWithToken { token in
            guard let token = token else {
                completion(nil, Error())
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
                        completion(nil, Error())
                    }
            }
        }
    }

    func getMultipleStorefronts(withIDs ids: [String], lang: String? = nil, completion: @escaping (_ storefront: Storefront?, _ error: Error?) -> Void) {
        callWithToken { token in
            guard let token = token else {
                completion(nil, Error())
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
                        let data = response["data"] as? [[String:Any]],
                        let resource = data.first,
                        let attributes = resource["attributes"] as? NSDictionary {
                        let storefront = Storefront(dictionary: attributes)
                        completion(storefront, nil)
                    } else {
                        completion(nil, Error())
                    }
            }
        }
    }

    func getAllStorefronts(lang: String? = nil, limit: Int? = nil, offset: Int? = nil, completion: @escaping (_ storefront: Storefront?, _ error: Error?) -> Void) {
        callWithToken { token in
            guard let token = token else {
                completion(nil, Error())
                return
            }
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            var url = "https://api.music.apple.com/v1/storefronts"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            if let limit = limit {
                url = url + ""
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
                        completion(nil, Error())
                    }
            }
        }
    }

}
