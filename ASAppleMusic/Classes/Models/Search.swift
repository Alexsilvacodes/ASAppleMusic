//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

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
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *AnyObject*, *AMError*
     - results: the `[AnyObject]` array of results
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/search?term=james+brown&limit=2&types=artists,albums*
     */
    func searchTerm(_ term: String, fromStorefrontID storeID: String, lang: String? = nil, limit: Int? = nil, offset: Int? = nil, types: [String]? = nil, completion: @escaping (_ results: [AnyObject]?, _ error: AMError?) -> Void) {
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
                url = url + "?" + params.joined(separator: "&")
            }
            Alamofire.SessionManager.default.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let results = response["results"] as? [String:Any] {
                        var resultObjects: [AnyObject] = []

                        if let activitiesData = results["activities"] as? [String:Any],
                            let activities = activitiesData["data"] as? [[String:Any]] {
                            activities.forEach { activityData in
                                if let activity = activityData["attributes"] as? NSDictionary {
                                    resultObjects.append(AMActivity(dictionary: activity))
                                }
                            }
                        }
                        if let artistsData = results["artists"] as? [String:Any],
                            let artists = artistsData["data"] as? [[String:Any]] {
                            artists.forEach { artistData in
                                if let artist = artistData["attributes"] as? NSDictionary {
                                    resultObjects.append(AMArtist(dictionary: artist))
                                }
                            }
                        }
                        if let appleCuratorsData = results["apple-curators"] as? [String:Any],
                            let appleCurators = appleCuratorsData["data"] as? [[String:Any]] {
                            appleCurators.forEach { appleCuratorData in
                                if let appleCurator = appleCuratorData["attributes"] as? NSDictionary {
                                    resultObjects.append(AMAppleCurator(dictionary: appleCurator))
                                }
                            }
                        }
                        if let albumsData = results["albums"] as? [String:Any],
                            let albums = albumsData["data"] as? [[String:Any]] {
                            albums.forEach { albumData in
                                if let album = albumData["attributes"] as? NSDictionary {
                                    resultObjects.append(AMAlbum(dictionary: album))
                                }
                            }
                        }
                        if let curatorsData = results["curators"] as? [String:Any],
                            let curators = curatorsData["data"] as? [[String:Any]] {
                            curators.forEach { curatorData in
                                if let curator = curatorData["attributes"] as? NSDictionary {
                                    resultObjects.append(AMCurator(dictionary: curator))
                                }
                            }
                        }
                        if let songsData = results["songs"] as? [String:Any],
                            let songs = songsData["data"] as? [[String:Any]] {
                            songs.forEach { songData in
                                if let song = songData["attributes"] as? NSDictionary {
                                    resultObjects.append(AMSong(dictionary: song))
                                }
                            }
                        }
                        if let playlistsData = results["playlists"] as? [String:Any],
                            let playlists = playlistsData["data"] as? [[String:Any]] {
                            playlists.forEach { playlistData in
                                if let playlist = playlistData["attributes"] as? NSDictionary {
                                    resultObjects.append(AMPlaylist(dictionary: playlist))
                                }
                            }
                        }
                        if let musicVideosData = results["music-videos"] as? [String:Any],
                            let musicVideos = musicVideosData["data"] as? [[String:Any]] {
                            musicVideos.forEach { musicVideoData in
                                if let musicVideo = musicVideoData["attributes"] as? NSDictionary {
                                    resultObjects.append(AMMusicVideo(dictionary: musicVideo))
                                }
                            }
                        }
                        if let stationsData = results["stations"] as? [String:Any],
                            let stations = stationsData["data"] as? [[String:Any]] {
                            stations.forEach { stationData in
                                if let station = stationData["attributes"] as? NSDictionary {
                                    resultObjects.append(AMStation(dictionary: station))
                                }
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

    /**
     Get Search hints that may be helpful for autocompletion based on the `term` and the Storefront ID of the store

     - Parameters:
     - term: The term of the content that you want to find. Example: `"james+brown"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - limit: (Optional) The limit of stores to get
     - types: (Optional) The list of the types of resources to include in the results. Values: `activities`, `artists`, `apple-curators`, `albums`, `curators`, `songs`, `playlists`, `music-videos`, and `stations`
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[String]*, *AMError*
     - resultTerms: the `[String]` array of results
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/search/hints?term=love&limit=10*
     */
    func getSearchHints(_ term: String, fromStorefrontID storeID: String, lang: String? = nil, limit: Int? = nil, types: [String]? = nil, completion: @escaping (_ resultTerms: [String]?, _ error: AMError?) -> Void) {
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
                url = url + "?" + params.joined(separator: "&")
            }
            Alamofire.SessionManager.default.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let results = response["results"] as? [String:Any],
                        let resultTerms = results["terms"] as? [String] {
                        completion(resultTerms, nil)
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
