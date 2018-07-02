//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 Genre object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/genre)
 */
public class AMGenre: EVObject {

    /// The localized name of the genre
    public var name: String?

}

public extension ASAppleMusic {

    /**
     Get Genre based on the id of the `storefront` and the genre `id`

     - Parameters:
     - id: The id of the genre (Number). Example: `"14"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Genre*, *AMError*
     - genre: the `Genre` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/genres/14*
     */
    func getGenre(withID id: String, storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ genre: AMGenre?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/genres/\(id)"
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
                        let genre = AMGenre(dictionary: attributes)
                        completion(genre, nil)
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
     Get several Genre objects based on the `ids` of the genres that you want to get and the Storefront ID of the store

     - Parameters:
     - ids: An id array of the genres. Example: `["14", "20"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[Genre]*, *AMError*
     - genres: the `[Genre]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/genres?ids=14,20*
     */
    func getMultipleGenres(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil, completion: @escaping (_ genres: [AMGenre]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/genres?ids=\(ids.joined(separator: ","))"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var genres: [AMGenre]?
                        if resources.count > 0 {
                            genres = []
                        }
                        resources.forEach { genreData in
                            if let attributes = genreData["attributes"] as? NSDictionary {
                                let genre = AMGenre(dictionary: attributes)
                                genres?.append(genre)
                            }
                        }
                        completion(genres, nil)
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
     Get the top charts Genres. You can decide the limit of stores to get and the offset per page as *Optional* parameters

     - Parameters:
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - limit: (Optional) The limit of genres to get
     - offset: (Optional) The *page* of the results to get
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[Genre]*, *AMError*
     - genres: the `[Genre]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/genres?l=en-us&limit=2&offset=2*
     */
    func getTopGenres(storefrontID storeID: String, lang: String? = nil, limit: Int? = nil, offset: Int? = nil, completion: @escaping (_ genres: [AMGenre]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/genres"
            var params: [String] = []
            if let lang = lang {
                params.append("l=\(lang)")
            }
            if let limit = limit {
                params.append("limit=\(limit)")
            }
            if let offset = offset {
                params.append("offset=\(offset)")
            }
            if !params.isEmpty {
                url = url + "?" + params.joined(separator: "&")
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var genres: [AMGenre]?
                        if resources.count > 0 {
                            genres = []
                        }
                        resources.forEach { genreData in
                            if let attributes = genreData["attributes"] as? NSDictionary {
                                genres?.append(AMGenre(dictionary: attributes))
                            }
                        }
                        completion(genres, nil)
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
