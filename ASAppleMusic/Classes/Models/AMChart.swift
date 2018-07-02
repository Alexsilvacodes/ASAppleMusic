//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

public enum AMChartType: String {
    case albums = "albums"
    case musicVideos = "music-videos"
    case songs = "songs"
    case playlists = "playlists"
}

/**
 Chart object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/chart)
 */
public class AMChart: EVObject {

    /// The localized name for the chart
    public var name: String?

    /// The chart identifier
    public var chart: String?

    /// The URL for the chart
    public var href: String?

    /// An array of the objects that were requested ordered by popularity
    public var data: [AnyObject]?

    /// Chart type: `albums`, `music-videos` and `songs`
    public var type: AMChartType?

    /// (Optional) The URL for the next page
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
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Curator*, *AMError*
     - curator: the `Curator` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/curators/1217688517*
     */
    func getCharts(_ types: [String], fromStorefrontID storeID: String, lang: String? = nil, chart: String? = nil, genre: String? = nil, limit: Int? = nil, offset: Int? = nil, completion: @escaping (_ charts: [AMChart]?, _ error: AMError?) -> Void) {
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
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let results = response["results"] as? [String:Any] {
                        var resultObjects: [AMChart] = []

                        if let albums = results["albums"] as? [NSDictionary] {
                            albums.forEach { album in
                                let chart = AMChart(dictionary: album)
                                chart.type = .albums
                                resultObjects.append(chart)
                            }
                        }
                        if let songs = results["songs"] as? [NSDictionary] {
                            songs.forEach { song in
                                let chart = AMChart(dictionary: song)
                                chart.type = .songs
                                resultObjects.append(chart)
                            }
                        }
                        if let musicVideos = results["music-videos"] as? [NSDictionary] {
                            musicVideos.forEach { musicVideo in
                                let chart = AMChart(dictionary: musicVideo)
                                chart.type = .musicVideos
                                resultObjects.append(chart)
                            }
                        }
                        completion(resultObjects, nil)
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
