//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Storefront object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/storefront)
 */
public class AMStorefront: Codable, AMResource {

    public class Attributes: Codable {

        /// (Required) The default language for the storefront, represented as a language tag.
        public var defaultLanguageTag: String = ""

        /// (Required) The localized name of the storefront.
        public var name: String = ""

        /// (Required) The localizations that the storefront supports, represented as an array of language tags.
        public var supportedLanguageTags: [String] = []

    }

    public class Response: Codable {

        /// (Required) The data included in the response for a storefront object request.
        public var data: [AMStorefront]?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the request that generated the response data or results; not present in a request.
        public var href: String?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

    /// The attributes for the storefront.
    public var attributes: Attributes?

    // Always storefronts.
    public var type: String = "storefronts"

}

public extension ASAppleMusic {
    
    /**
     Get User's Storefront
     
     - Parameters:
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Storefront*, *AMError*
     - storefront: the `Storefront` object itself
     - error: if the request you will get an `AMError` object
     
     **Example:** *https://api.music.apple.com/v1/me/storefront*
     */
    func getUserStorefront(withLang lang: String? = nil, completion: @escaping (_ storefront: AMStorefront?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/me/storefront"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
            request.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
            URLSession.init().dataTask(with: request, completionHandler: { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMStorefront.Response.self, from: data),
                        let amError = response.errors?.first {
                        completion(nil, amError)
                    } else {
                        let amError = AMError()
                        if let response = response, let statusCode = response.getStatusCode(),
                            let code = Code(rawValue: String(statusCode * 100)) {
                            amError.status = String(statusCode)
                            amError.code = code
                        }
                        amError.detail = error.localizedDescription
                        completion(nil, amError)
                    }
                } else if let data = data {
                    self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    let response = try? decoder.decode(AMStorefront.Response.self, from: data)
                    completion(response?.data?.first, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }
    
    /**
     Get Storefront based on the `id` of the store

     - Parameters:
        - id: The id of the store in two-letter code. Example: `"us"`
        - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
        - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Storefront*, *AMError*
        - storefront: the `Storefront` object itself
        - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/storefronts/us*
     */
    func getStorefront(withID id: String, lang: String? = nil, completion: @escaping (_ storefront: AMStorefront?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/storefronts/\(id)"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            URLSession.init().dataTask(with: request, completionHandler: { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMStorefront.Response.self, from: data),
                        let amError = response.errors?.first {
                        completion(nil, amError)
                    } else {
                        let amError = AMError()
                        if let response = response, let statusCode = response.getStatusCode(),
                            let code = Code(rawValue: String(statusCode * 100)) {
                            amError.status = String(statusCode)
                            amError.code = code
                        }
                        amError.detail = error.localizedDescription
                        completion(nil, amError)
                    }
                } else if let data = data {
                    self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    let response = try? decoder.decode(AMStorefront.Response.self, from: data)
                    completion(response?.data?.first, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

    /**
     Get several Storefront objects based on the `ids` of the stores that you want to get

     - Parameters:
         - ids: An id array of the stores in two-letter code. Example: `["us", "es", "jp"]`
         - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
         - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Storefront*, *AMError*
         - storefront: the `Storefront` object itself
         - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/storefronts?ids=us,es,jp*
     */
    func getMultipleStorefronts(withIDs ids: [String], lang: String? = nil, completion: @escaping (_ storefronts: [AMStorefront]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/storefronts?ids=\(ids.joined(separator: ","))&"
            if let lang = lang {
                url = url + "l=\(lang)"
            }
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            URLSession.init().dataTask(with: request, completionHandler: { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMStorefront.Response.self, from: data),
                        let amError = response.errors?.first {
                        completion(nil, amError)
                    } else {
                        let amError = AMError()
                        if let response = response, let statusCode = response.getStatusCode(),
                            let code = Code(rawValue: String(statusCode * 100)) {
                            amError.status = String(statusCode)
                            amError.code = code
                        }
                        amError.detail = error.localizedDescription
                        completion(nil, amError)
                    }
                } else if let data = data {
                    self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    let response = try? decoder.decode(AMStorefront.Response.self, from: data)
                    completion(response?.data, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

    /**
     Get all the Storefront objects. You can decide the limit of stores to get and the offset per page as *Optional* parameters

     - Parameters:
         - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
         - limit: (Optional) The limit of stores to get
         - offset: (Optional) The *page* of the results to get
         - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[Storefront]*, *AMError*
         - storefront: the `[Storefront]` array of objects
         - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/storefronts?l=en-us&limit=2&offset=2*
     */
    func getAllStorefronts(lang: String? = nil, limit: Int? = nil, offset: Int? = nil, completion: @escaping (_ storefronts: [AMStorefront]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/storefronts"
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
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            URLSession.init().dataTask(with: request, completionHandler: { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMStorefront.Response.self, from: data),
                        let amError = response.errors?.first {
                        completion(nil, amError)
                    } else {
                        let amError = AMError()
                        if let response = response, let statusCode = response.getStatusCode(),
                            let code = Code(rawValue: String(statusCode * 100)) {
                            amError.status = String(statusCode)
                            amError.code = code
                        }
                        amError.detail = error.localizedDescription
                        completion(nil, amError)
                    }
                } else if let data = data {
                    self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    let response = try? decoder.decode(AMStorefront.Response.self, from: data)
                    completion(response?.data, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

}
