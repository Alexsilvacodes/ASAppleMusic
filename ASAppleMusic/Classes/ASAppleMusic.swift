//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import StoreKit

public enum Rating: String {
    case clean = "clean"
    case explicit = "explicit"
    case noRating = ""
}

enum TrackType: String {
    case songs = "songs"
    case musicVideos = "music-videos"
}

/**
 The API that the framework will use

 - developer: uses developer API
 - user: uses user API
 */
public enum SourceAPI {
    case developer
    case user
}

/**
 Debug level to get on the Log console

 - none: shows nothing on console
 - verbose: shows URL Requests, errors and succesfully done requests
 */
public enum DebugLevel {
    case none
    case verbose
}

/**
 To use this class just call the singleton and each method to get the API object desired.
 By default the token used will be the Developer token and 0 logging, if you want to change it just change the value of `source` and `debugLevel` attributes.

 This API is configured as you should know how to generate developer and user tokens, for more info [visit the Apple Music API.](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/SetUpWebServices.html)

 You should create your own web server that receives parameters as `POST` request in the body in JSON format like:
 ````
 {
    "kid": "C234234AS",
    "tid": "AS234ASF2"
 }
 ````

 and should return the token in JSON format:
 ````
 {
    "token": "alf9dsahf92fjdsa.fdsaifjds89a4fh"
 }
 ````
 */
public class ASAppleMusic {

    /**
     ASAppleMusic singleton
     */
    public static var shared = ASAppleMusic()

    var token: String?

    /**
     SourceAPI token that will use to receive data
     */
    public var source: SourceAPI = .developer

    /**
     Debug Level for logs
     */
    public var debugLevel: DebugLevel = .none

    /**
     KeyID from the Developer account key
     */
    public var keyID: String?

    /**
     TeamID from the Developer account key
     */
    public var teamID: String?

    /**
     tokenServer URL from where you should get the token
     */
    public var tokenServer: String?

    // Private Initializer
    private init() {}

    func print(_ items: Any, separator: String = " ", terminator: String = "\n") {
        #if DEBUG
            if debugLevel == .verbose {
                Swift.print(items, separator: separator, terminator: terminator)
            }
        #endif
    }

    /**
     Initialises the Apple Music API.

     - Parameters:
     - keyID: The ID from the '.p8' file with the key from MusicKit
     - teamID: The ID from your Apple Developer account Team
     - tokenServer: Your own server that will generate the token with JWT. Follow the ASAppleMusic documentation to know more about this

     **Example:** *https://localhost/getToken*

     *To get the MusicKit API take a look at [the Apple Music API documentation](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/SetUpWebServices.html#//apple_ref/doc/uid/TP40017625-CH2-SW3)*
     */
    public func initialize(keyID: String, teamID: String, tokenServer: String) {
        self.keyID = keyID
        self.teamID = teamID
        self.tokenServer = tokenServer
    }

    func callWithToken(_ completion: @escaping (_ token: String?) -> Void) {
        switch source {
        case .developer:
            getDeveloperToken { token in
                completion(token)
            }
        case .user:
            getDeveloperToken { devToken in
                if let devToken = devToken {
                    let cloudService = SKCloudServiceController()
                    cloudService.requestUserToken(forDeveloperToken: devToken,
                                                  completionHandler: { userToken, error in
                        if let userToken = userToken {
                            completion(userToken)
                        } else {
                            completion(nil)
                        }
                    })
                } else {
                    completion(nil)
                }
            }
        }
    }

    private func getDeveloperToken(_ completion: @escaping (_ token: String?) -> Void) {
        guard let kid = keyID, let tid = teamID, let tokenServer = tokenServer else {
            self.print("[ASAppleMusic] 🛑: Missing token information for 'teamID'/'keyID'/'tokenServer'")
            completion(nil)
            return
        }
        let parameters = ["kid": kid, "tid": tid]
        Alamofire.request(tokenServer,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON { response in
                if let json = response.result.value as? [String:Any],
                    let token = json["token"] as? String {
                    completion(token)
                } else {
                    completion(nil)
                }
            }
    }
}
