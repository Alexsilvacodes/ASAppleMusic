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
}

extension ASAppleMusic {
    func makeCall(ofType type: CallType, withParams params: [String:String], _ completion: @escaping (AnyObject?, AMError?) -> Void) {
        switch type {
        case .getStorefront:
            ASAppleMusic.shared.getStorefront(withID: params["id"]!, lang: params["l"], completion: { storefront, error in
                completion(storefront, error)
            })
        case .getMultipleStorefronts:
            let paramsArray = params["ids"]!.components(separatedBy: ",")
            ASAppleMusic.shared.getMultipleStorefronts(withIDs: paramsArray, lang: params["l"], completion: { storefronts, error in
                completion(storefronts as AnyObject, error)
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
                completion(storefronts as AnyObject, error)
            })
        }
    }
}
