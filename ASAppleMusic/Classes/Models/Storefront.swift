//
//  Storefront.swift
//  ASAppleMusic
//
//  Copyright © 2018 Alex Silva. All rights reserved.
//

import Foundation

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Storefront.html

class Storefront: Resource {

    // MARK: Resource attributes
    var id: String
    var href: URL
    var meta: [String : Any]?

    // MARK: Storefront attributes
    var name: String
    var storefrontId: Int
    var supportedLanguageTags: [String]
    var defaultLanguageTag: String

    init(id: String, href: URL, name: String, storefrontId: Int, supportedLanguageTags: [String], defaultLanguageTag: String) {
        self.id = id
        self.href = href
        self.name = name
        self.storefrontId = storefrontId
        self.supportedLanguageTags = supportedLanguageTags
        self.defaultLanguageTag = defaultLanguageTag
    }
}

extension ASAppleMusic {
    // https://api.music.apple.com/v1/storefronts/{id}
    func getStorefront(withId id: String, completion: @escaping (_ storefront: Storefront?, _ error: Error?) -> Void) {
        let url = URL(string: "https://api.music.apple.com/v1/storefronts/\(id)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30.0)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                
            } else {
                if let error = error as? Error {
                    completion(nil, error)
                }
            }
        }
    }

    func getStorefront(withId id: String, l: String) {

    }
}
