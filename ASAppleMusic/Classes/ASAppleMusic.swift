//
//  ASAppleMusic.swift
//  ASAppleMusic
//
//  Copyright © 2018 Alex Silva. All rights reserved.
//

import Foundation

enum SourceAPI {
    case developer
    case user
}

class ASAppleMusic {

    static let shared = ASAppleMusic(source: .developer)

    // Initializer
    private init(source: SourceAPI) {
        ASAppleMusic(source: source)
    }
}
