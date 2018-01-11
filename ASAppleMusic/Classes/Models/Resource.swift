//
//  Resource.swift
//  ASAppleMusic
//
//  Copyright © 2018 Alex Silva. All rights reserved.
//

import Foundation

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Resourceobject.html

enum Rating {
    case clean
    case explicit
    case noRating
}

protocol Resource {

    var id: String { get set }
    var href: URL { get set }
    var meta: [String: Any]? { get set }
}
