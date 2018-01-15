//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import ASAppleMusic

enum CallType: String {
    case getStorefront = "getStorefront"
    case getMultipleStorefronts = "getMultipleStorefronts"
    case getAllStorefronts = "getAllStorefronts"
    case getAlbum = "getAlbum"
    case getMultipleAlbums = "getMultipleAlbums"
    case getMusicVideo = "getMusicVideo"
    case getMultipleMusicVideos = "getMultipleMusicVideos"
    case getPlaylist = "getPlaylist"
    case getMultiplePlaylists = "getMultiplePlaylists"
    case getSong = "getSong"
    case getMultipleSongs = "getMultipleSongs"
    case getStation = "getStation"
    case getMultipleStations = "getMultipleStations"
    case getArtist = "getArtist"
    case getMultipleArtists = "getMultipleArtists"
    case getCurator = "getCurator"
    case getMultipleCurators = "getMultipleCurators"
    case getActivity = "getActivity"
    case getMultipleActivities = "getMultipleActivities"
    case getAppleCurator = "getAppleCurator"
    case getMultipleAppleCurators = "getAppleCurators"
    case getGenre = "getGenre"
    case getMultipleGenres = "getMultipleGenres"
    case getTopGenres = "getTopGenres"
    case searchTerm = "searchTerm"
    case getSearchHints = "getSearchHints"
}

extension ASAppleMusic {
    func makeCall(ofType type: CallType, withParams params: [String:String], _ completion: @escaping (AnyObject?, AMError?) -> Void) {
        switch type {
        // Storefronts
        case .getStorefront:
            ASAppleMusic.shared.getStorefront(withID: params["id"]!, lang: params["l"], completion: { storefront, error in
                completion(storefront, error)
            })
        case .getMultipleStorefronts:
            let ids = params["ids"]!.components(separatedBy: ",")
            ASAppleMusic.shared.getMultipleStorefronts(withIDs: ids, lang: params["l"], completion: { storefronts, error in
                if let storefronts = storefronts {
                    completion(storefronts as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        case .getAllStorefronts:
            var limit: Int? = nil
            var offset: Int? = nil
            if let limitStr = params["limit"] {
                limit = Int(limitStr)
            }
            if let offsetStr = params["offset"] {
                offset = Int(offsetStr)
            }
            ASAppleMusic.shared.getAllStorefronts(lang: params["l"], limit: limit, offset: offset, completion: { storefronts, error in
                if let storefronts = storefronts {
                    completion(storefronts as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })

        // Albums
        case .getAlbum:
            ASAppleMusic.shared.getAlbum(withID: params["id"]!, storefrontID: params["storeID"]!, lang: params["l"], completion: { album, error in
                completion(album, error)
            })
        case .getMultipleAlbums:
            let ids = params["ids"]!.components(separatedBy: ",")
            ASAppleMusic.shared.getMultipleAlbums(withIDs: ids, storefrontID: params["storeID"]!, lang: params["l"], completion: { albums, error in
                if let albums = albums {
                    completion(albums as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })

        // Music Videos
        case .getMusicVideo:
            ASAppleMusic.shared.getMusicVideo(withID: params["id"]!, storefrontID: params["storeID"]!, lang: params["l"], completion: { musicVideo, error in
                completion(musicVideo, error)
            })
        case .getMultipleMusicVideos:
            let ids = params["ids"]!.components(separatedBy: ",")
            ASAppleMusic.shared.getMultipleMusicVideos(withIDs: ids, storefrontID: params["storeID"]!, lang: params["l"], completion: { musicVideos, error in
                if let musicVideos = musicVideos {
                    completion(musicVideos as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })

        // Playlists
        case .getPlaylist:
            ASAppleMusic.shared.getPlaylist(withID: params["id"]!, storefrontID: params["storeID"]!, lang: params["l"], completion: { playlist, error in
                completion(playlist, error)
            })
        case .getMultiplePlaylists:
            let ids = params["ids"]!.components(separatedBy: ",")
            ASAppleMusic.shared.getMultiplePlaylists(withIDs: ids, storefrontID: params["storeID"]!, lang: params["l"], completion: { playlists, error in
                if let playlists = playlists {
                    completion(playlists as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })

        // Songs
        case .getSong:
            ASAppleMusic.shared.getSong(withID: params["id"]!, storefrontID: params["storeID"]!, lang: params["l"], completion: { song, error in
                completion(song, error)
            })
        case .getMultipleSongs:
            let ids = params["ids"]!.components(separatedBy: ",")
            ASAppleMusic.shared.getMultipleSongs(withIDs: ids, storefrontID: params["storeID"]!, lang: params["l"], completion: { songs, error in
                if let songs = songs {
                    completion(songs as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })

        // Stations
        case .getStation:
            ASAppleMusic.shared.getStation(withID: params["id"]!, storefrontID: params["storeID"]!, lang: params["l"], completion: { station, error in
                completion(station, error)
            })
        case .getMultipleStations:
            let ids = params["ids"]!.components(separatedBy: ",")
            ASAppleMusic.shared.getMultipleStations(withIDs: ids, storefrontID: params["storeID"]!, lang: params["l"], completion: { stations, error in
                if let stations = stations {
                    completion(stations as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })

        // Artists
        case .getArtist:
            ASAppleMusic.shared.getArtist(withID: params["id"]!, storefrontID: params["storeID"]!, lang: params["l"], completion: { artist, error in
                completion(artist, error)
            })
        case .getMultipleArtists:
            let ids = params["ids"]!.components(separatedBy: ",")
            ASAppleMusic.shared.getMultipleArtists(withIDs: ids, storefrontID: params["storeID"]!, lang: params["l"], completion: { artists, error in
                if let artists = artists {
                    completion(artists as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })

        // Curator
        case .getCurator:
            ASAppleMusic.shared.getCurator(withID: params["id"]!, storefrontID: params["storeID"]!, lang: params["l"], completion: { curator, error in
                completion(curator, error)
            })
        case .getMultipleCurators:
            let ids = params["ids"]!.components(separatedBy: ",")
            ASAppleMusic.shared.getMultipleCurators(withIDs: ids, storefrontID: params["storeID"]!, lang: params["l"], completion: { curators, error in
                if let curators = curators {
                    completion(curators as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })

        // Activity
        case .getActivity:
            ASAppleMusic.shared.getActivity(withID: params["id"]!, storefrontID: params["storeID"]!, lang: params["l"], completion: { activity, error in
                completion(activity, error)
            })
        case .getMultipleActivities:
            let ids = params["ids"]!.components(separatedBy: ",")
            ASAppleMusic.shared.getMultipleCurators(withIDs: ids, storefrontID: params["storeID"]!, lang: params["l"], completion: { activities, error in
                if let activities = activities {
                    completion(activities as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })

        // Apple Curators
        case .getAppleCurator:
            ASAppleMusic.shared.getAppleCurator(withID: params["id"]!, storefrontID: params["storeID"]!, lang: params["l"], completion: { appleCurator, error in
                completion(appleCurator, error)
            })
        case .getMultipleAppleCurators:
            let ids = params["ids"]!.components(separatedBy: ",")
            ASAppleMusic.shared.getMultipleAppleCurators(withIDs: ids, storefrontID: params["storeID"]!, lang: params["l"], completion: { appleCurators, error in
                if let appleCurators = appleCurators {
                    completion(appleCurators as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })

        // Genres
        case .getGenre:
            ASAppleMusic.shared.getGenre(withID: params["id"]!, storefrontID: params["storeID"]!, lang: params["l"], completion: { genre, error in
                completion(genre, error)
            })
        case .getMultipleGenres:
            let ids = params["ids"]!.components(separatedBy: ",")
            ASAppleMusic.shared.getMultipleGenres(withIDs: ids, storefrontID: params["storeID"]!, lang: params["l"], completion: { genres, error in
                if let genres = genres {
                    completion(genres as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        case .getTopGenres:
            var limit: Int? = nil
            var offset: Int? = nil
            if let limitStr = params["limit"] {
                limit = Int(limitStr)
            }
            if let offsetStr = params["offset"] {
                offset = Int(offsetStr)
            }
            ASAppleMusic.shared.getTopGenres(storefrontID: params["storeID"]!, lang: params["l"], limit: limit, offset: offset, completion: { genres, error in
                if let genres = genres {
                    completion(genres as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })

        // Search
        case .searchTerm:
            var limit: Int? = nil
            var offset: Int? = nil
            var types: [String]? = nil
            if let limitStr = params["limit"] {
                limit = Int(limitStr)
            }
            if let offsetStr = params["offset"] {
                offset = Int(offsetStr)
            }
            if let typesStr = params["types"] {
                types = typesStr.components(separatedBy: ",")
            }
            ASAppleMusic.shared.searchTerm(params["term"]!, fromStorefrontID: params["storeID"]!, lang: params["l"], limit: limit, offset: offset, types: types, completion: { results, error in
                if let results = results {
                    completion(results as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })
        case .getSearchHints:
            var limit: Int? = nil
            var types: [String]? = nil
            if let limitStr = params["limit"] {
                limit = Int(limitStr)
            }
            if let typesStr = params["types"] {
                types = typesStr.components(separatedBy: ",")
            }
            ASAppleMusic.shared.getSearchHints(params["term"]!, fromStorefrontID: params["storeID"]!, lang: params["l"], limit: limit, types: types, completion: { results, error in
                if let results = results {
                    completion(results as AnyObject, error)
                } else {
                    completion(nil, error)
                }
            })

        }
    }
}
