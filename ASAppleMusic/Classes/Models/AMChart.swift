//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Chart object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/chart)
 */
public class AMChart: Codable {

    public class Response: Codable {

        public class Results: Codable {

            /// The albums returned when fetching charts.
            public var albums: [AMChart]?

            /// The music videos returned when fetching charts.
            public var musicVideos: [AMChart]?

            /// The songs returned when fetching charts.
            public var songs: [AMChart]?

            enum CodingKeys: String, CodingKey {
                case albums
                case musicVideos = "music-videos"
                case songs
            }

        }

        /// The results including charts for each type.
        public var results: Results?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

    }

    /// (Required) The chart identifier.
    public var chart: String = ""

    /// (Required) An array of the requested objects, ordered by popularity. For example, if songs were specified as the chart type in the request, the array contains Song objects.
    public var data: [AMResource] = []

    /// (Required) The URL for the chart.
    public var href: String = ""

    /// (Required) The localized name for the chart.
    public var name: String = ""

    /// The URL for the next page.
    public var next: String?

}

public extension ASAppleMusic {

    /**
     Get Chart based on the id of the `storefront` and the `types` of the chart

     - Parameters:
     - types: Array of chart types to get. Example: `["albums", "songs"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - chart: (Optional) String that describes the chart. Example: `"most-played"`
     - genre: (Optional) Genre ID type to get the charts (Number). Example: `"13"`
     - limit: (Optional) The limit of stores to get. Example: `"2"`
     - offset: (Optional) The *page* of the results to get. Example `"2"`
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Results*, *AMError*
     - curator: the `Curator` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/charts?types=songs,albums,playlists&genre=20&limit=1*
     */
    func getCharts(_ types: [String], fromStorefrontID storeID: String, lang: String? = nil, chart: String? = nil, genre: String? = nil, limit: Int? = nil, offset: Int? = nil, completion: @escaping (_ charts: AMChart.Response.Results?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/charts?types=\(types.joined(separator: ","))"
            var params: [String] = []
            if let lang = lang {
                params.append("l=\(lang)")
            }
            if let chart = chart {
                params.append("chart=\(chart)")
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
                    if let data = data, let response = try? decoder.decode(AMChart.Response.self, from: data),
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
                    let response = try? decoder.decode(AMChart.Response.self, from: data)
                    completion(response?.results, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

}
