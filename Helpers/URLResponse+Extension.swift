//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

public extension URLResponse {

    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }

}
