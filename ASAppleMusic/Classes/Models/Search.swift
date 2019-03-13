//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

public class AMSearch: Decodable {

    public class Response: Decodable {

        public class Results: Decodable {

            /// The activities returned for the search query.
            public var activities: [AMActivity.Response]?

            /// The albums returned for the search query.
            public var albums: [AMAlbum.Response]?

            /// The Apple curators returned for the search query.
            public var appleCurators: [AMAppleCurator.Response]?

            /// The artists returned for the search query.
            public var artists: [AMArtist.Response]?

            /// The curators returned for the search query.
            public var curators: [AMCurator.Response]?

            /// The music videos returned for the search query.
            public var musicVideos: [AMMusicVideo.Response]?

            /// The playlists returned for the search query.
            public var playlists: [AMPlaylist.Response]?

            /// The songs returned for the search query.
            public var songs: [AMSong.Response]?

            /// The stations returned for the search query.
            public var stations: [AMStation.Response]?

            enum CodingKeys: String, CodingKey {
                case activities
                case albums
                case appleCurators = "apple-curators"
                case artists
                case curators
                case musicVideos = "music-videos"
                case playlists
                case songs
                case stations
            }

        }

        /// The results including charts for each type.
        public var results: Results?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

}

public class AMSearchHints: Decodable {

    public class Response: Decodable {

        /// (Required) The results included in the response for a search hints request.
        public var results: AMSearchHints = AMSearchHints()

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

    /// (Required) The autocomplete options derived from the search hint.
    public var terms: [String] = []

}

/**
 Searches whatever type of content. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/search_for_catalog_resources)
 */
public extension ASAppleMusic {

    /**
     Get search results based on the id of the `storefront` and the `term` that you want to find

     - Parameters:
     - term: The term of the content that you want to find. Example: `"james+brown"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - limit: (Optional) The limit of stores to get
     - offset: (Optional) The *page* of the results to get
     - types: (Optional) The list of the types of resources to include in the results. Values: `activities`, `artists`, `apple-curators`, `albums`, `curators`, `songs`, `playlists`, `music-videos`, and `stations`
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Results*, *AMError*
     - results: the `[AnyObject]` array of results
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/search?term=james+brown&limit=2&types=artists,albums*
     */
    func searchTerm(_ term: String, fromStorefrontID storeID: String, lang: String? = nil, limit: Int? = 25, offset: Int? = nil, types: [String]? = nil, completion: @escaping (_ results: AMSearch.Response.Results?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/search?term=\(term.replacingOccurrences(of: " ", with: "+"))"
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
            if let types = types {
                let typesString = types.joined(separator: ",")
                params.append("types=\(typesString)")
            }
            if !params.isEmpty {
                url = url + "&" + params.joined(separator: "&")
            }
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMSearch.Response.self, from: data),
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
                    let response = try? decoder.decode(AMSearch.Response.self, from: data)
                    completion(response?.results, nil)
                } else {
                    completion(nil, nil)
                }
            }
            task.resume()
        }
    }

    /**
     Get Search hints that may be helpful for autocompletion based on the `term` and the Storefront ID of the store

     - Parameters:
     - term: The term of the content that you want to find. Example: `"james+brown"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - limit: (Optional) The limit of stores to get
     - types: (Optional) The list of the types of resources to include in the results. Values: `activities`, `artists`, `apple-curators`, `albums`, `curators`, `songs`, `playlists`, `music-videos`, and `stations`
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[AMSearchHints]*, *AMError*
     - resultTerms: the `[String]` array of results
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/search/hints?term=love&limit=10*
     */
    func getSearchHints(_ term: String, fromStorefrontID storeID: String, lang: String? = nil, limit: Int? = nil, types: [String]? = nil, completion: @escaping (_ resultTerms: AMSearchHints?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/search/hints?term=\(term.replacingOccurrences(of: " ", with: "+")))"
            var params: [String] = []
            if let lang = lang {
                params.append("l=\(lang)")
            }
            if let limit = limit {
                params.append("limit=\(limit)")
            }
            if let types = types {
                let typesString = types.joined(separator: ",")
                params.append("types=\(typesString)")
            }
            if !params.isEmpty {
                url = url + "&" + params.joined(separator: "&")
            }
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMSearchHints.Response.self, from: data),
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
                    let response = try? decoder.decode(AMSearchHints.Response.self, from: data)
                    completion(response?.results, nil)
                } else {
                    completion(nil, nil)
                }
            }
            task.resume()
        }
    }

}
