//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire

enum SourceAPI {
    case developer
    case user
}

public class ASAppleMusic {

    public static let shared = ASAppleMusic()

    var token: String?
    var source: SourceAPI = .developer

    // Private Initializer
    private init() {}

    func callWithToken(_ completion: @escaping (_ token: String?) -> Void) {
        switch source {
        case .developer:
            getDeveloperToken { token in
                completion(token)
            }
        case .user:
            completion(nil)
        }
    }

    private func getDeveloperToken(_ completion: @escaping (_ token: String?) -> Void) {
        let parameters = ["kid": "x", "tid": "x"]
        Alamofire.request("x",
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
