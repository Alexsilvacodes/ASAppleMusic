//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 Searches whatever type of content. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Searchforresources.html)
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/search?term=\(term)"
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
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    if let response = response.result.value as? [String:Any],
                        let results = response["results"] as? [String:Any] {
                        var resultObjects: [AnyObject] = []

                        if let activitiesData = results["activities"] as? [String:Any],
                            let activities = activitiesData["data"] as? [NSDictionary] {
                            activities.forEach { activity in
                                resultObjects.append(Activity(dictionary: activity))
                            }
                        }
                        if let artistsData = results["artists"] as? [String:Any],
                            let artists = artistsData["data"] as? [NSDictionary] {
                            artists.forEach { artist in
                                resultObjects.append(Artist(dictionary: artist))
                            }
                        }
                        if let appleCuratorsData = results["apple-curators"] as? [String:Any],
                            let appleCurators = appleCuratorsData["data"] as? [NSDictionary] {
                            appleCurators.forEach { appleCurator in
                                resultObjects.append(AppleCurator(dictionary: appleCurator))
                            }
                        }
                        if let albumsData = results["albums"] as? [String:Any],
                            let albums = albumsData["data"] as? [NSDictionary] {
                            albums.forEach { album in
                                resultObjects.append(Album(dictionary: album))
                            }
                        }
                        if let curatorsData = results["curators"] as? [String:Any],
                            let curators = curatorsData["data"] as? [NSDictionary] {
                            curators.forEach { curator in
                                resultObjects.append(Curator(dictionary: curator))
                            }
                        }
                        if let songsData = results["songs"] as? [String:Any],
                            let songs = songsData["data"] as? [NSDictionary] {
                            songs.forEach { song in
                                resultObjects.append(Song(dictionary: song))
                            }
                        }
                        if let playlistsData = results["playlists"] as? [String:Any],
                            let playlists = playlistsData["data"] as? [NSDictionary] {
                            playlists.forEach { playlist in
                                resultObjects.append(Playlist(dictionary: playlist))
                            }
                        }
                        if let musicVideosData = results["music-videos"] as? [String:Any],
                            let musicVideos = musicVideosData["data"] as? [NSDictionary] {
                            musicVideos.forEach { musicVideo in
                                resultObjects.append(MusicVideo(dictionary: musicVideo))
                            }
                        }
                        if let stationsData = results["stations"] as? [String:Any],
                            let stations = stationsData["data"] as? [NSDictionary] {
                            stations.forEach { station in
                                resultObjects.append(Station(dictionary: station))
                            }
                        }
                        completion(resultObjects, nil)
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
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *AnyObject*, *AMError*
     - results: the `[AnyObject]` array of results
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/search/hints?term=love&limit=10*
     */
    func getSearchHints(_ term: String, fromStorefrontID storeID: String, lang: String? = nil, limit: Int? = nil, types: [String]? = nil, completion: @escaping (_ results: [AnyObject]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/search/hints?term=\(term))"
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
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    if let response = response.result.value as? [String:Any],
                        let results = response["results"] as? [String:Any] {
                        var resultObjects: [AnyObject] = []

                        if let activitiesData = results["activities"] as? [String:Any],
                            let activities = activitiesData["data"] as? [NSDictionary] {
                            activities.forEach { activity in
                                resultObjects.append(Activity(dictionary: activity))
                            }
                        }
                        if let artistsData = results["artists"] as? [String:Any],
                            let artists = artistsData["data"] as? [NSDictionary] {
                            artists.forEach { artist in
                                resultObjects.append(Artist(dictionary: artist))
                            }
                        }
                        if let appleCuratorsData = results["apple-curators"] as? [String:Any],
                            let appleCurators = appleCuratorsData["data"] as? [NSDictionary] {
                            appleCurators.forEach { appleCurator in
                                resultObjects.append(AppleCurator(dictionary: appleCurator))
                            }
                        }
                        if let albumsData = results["albums"] as? [String:Any],
                            let albums = albumsData["data"] as? [NSDictionary] {
                            albums.forEach { album in
                                resultObjects.append(Album(dictionary: album))
                            }
                        }
                        if let curatorsData = results["curators"] as? [String:Any],
                            let curators = curatorsData["data"] as? [NSDictionary] {
                            curators.forEach { curator in
                                resultObjects.append(Curator(dictionary: curator))
                            }
                        }
                        if let songsData = results["songs"] as? [String:Any],
                            let songs = songsData["data"] as? [NSDictionary] {
                            songs.forEach { song in
                                resultObjects.append(Song(dictionary: song))
                            }
                        }
                        if let playlistsData = results["playlists"] as? [String:Any],
                            let playlists = playlistsData["data"] as? [NSDictionary] {
                            playlists.forEach { playlist in
                                resultObjects.append(Playlist(dictionary: playlist))
                            }
                        }
                        if let musicVideosData = results["music-videos"] as? [String:Any],
                            let musicVideos = musicVideosData["data"] as? [NSDictionary] {
                            musicVideos.forEach { musicVideo in
                                resultObjects.append(MusicVideo(dictionary: musicVideo))
                            }
                        }
                        if let stationsData = results["stations"] as? [String:Any],
                            let stations = stationsData["data"] as? [NSDictionary] {
                            stations.forEach { station in
                                resultObjects.append(Station(dictionary: station))
                            }
                        }
                        completion(resultObjects, nil)
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
