//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
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

public protocol AMTrack: Decodable { }

public protocol AMLibraryTrack: Decodable { }

public protocol AMResource: Decodable, CustomStringConvertible { }

public extension CustomStringConvertible {

    public var description : String {
        var description: String = "***** \(type(of: self)) *****\n"
        description += diveMirror(object: self)
        return description
    }

    private func diveMirror(object: Any) -> String {
        var description = ""
        let selfMirror = Mirror(reflecting: object)
        selfMirror.children.forEach { child in
            if let propertyName = child.label {
                if !Mirror(reflecting: child.value).children.isEmpty {
                    description += "\(propertyName):\n"
                    description += "\t - " + diveMirror(object: child.value)
                } else {
                    description += "\(propertyName): \(child.value)\n"
                }
            }
        }
        return description
    }

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
    
    func callWithToken(_ completion: @escaping (_ devToken: String?) -> Void) {
        callWithToken { (devToken, nil) in
            completion(devToken)
        }
    }

    func callWithToken(_ completion: @escaping (_ devToken: String?, _ userToken: String?) -> Void) {
        switch source {
        case .developer:
            getDeveloperToken { devToken in
                completion(devToken, nil)
            }
        case .user:
            getDeveloperToken { devToken in
                if let devToken = devToken {
                    let cloudService = SKCloudServiceController()
                    SKCloudServiceController.requestAuthorization { status in
                        if status == .authorized {
                            cloudService.requestUserToken(forDeveloperToken: devToken, completionHandler: { (userToken, error) in
                                if let userToken = userToken {
                                    completion(devToken, userToken)
                                } else {
                                    completion(devToken, nil)
                                }
                            })
                        } else {
                            completion(nil, nil)
                        }
                    }
                } else {
                    completion(nil, nil)
                }
            }
        }
    }

    private func getDeveloperToken(_ completion: @escaping (_ token: String?) -> Void) {
        guard let kid = keyID, let tid = teamID, let tokenServer = tokenServer,
            let serverURL = URL(string: tokenServer) else {
            self.print("[ASAppleMusic] 🛑: Missing token information for 'teamID'/'keyID'/'tokenServer'")
            completion(nil)
            return
        }
        let json = ["kid": kid, "tid": tid]
        let jsonData = try! JSONSerialization.data(withJSONObject: json)

        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                completion(nil)
            } else {
                guard let data = data, let jsonDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let jsonAux = jsonDict, let token = jsonAux["token"] as? String else {
                        completion(nil)
                        return
                }
                completion(token)
            }
        }
        task.resume()
    }
}
