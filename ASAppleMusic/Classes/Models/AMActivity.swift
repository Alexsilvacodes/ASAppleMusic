//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Activity object representation. For more information take a look at\
 [Apple Music API](https://developer.apple.com/documentation/applemusicapi/activity)
 */
public class AMActivity: Decodable, AMResource  {

    public class Attributes: Decodable {

        /// (Required) The activity artwork
        public var artwork: AMArtwork = AMArtwork()

        /// The notes about the activity that appear in the iTunes Store
        public var editorialNotes: AMEditorialNotes?

        /// (Required) The localized name of the activity
        public var name: String = ""
        
        /// (Required) The URL for sharing an activity in the iTunes Store
        public var url: String = ""

    }

    public class Relationships: Decodable {

        /// The playlists associated with this activity. By default, playlists includes identifiers only.
        public var playlists: AMRelationship.Playlist?
        
    }

    public class Response: Decodable {

        /// The data included in the response to an activity object request.
        public var data: [AMActivity]?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the request that generated the response data or results; not present in a request.
        public var href: String?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

    /// The attributes for the activity.
    public var attributes: Attributes?

    /// The relationships for the activity.
    public var relationships: Relationships?

    // Always activities.
    public var type: String = "activities"

    public enum CodingKeys: String, CodingKey {
        case attributes
        case relationships
        case type
    }

}

public extension ASAppleMusic {

    /**
     Get Activity based on the id of the `storefront` and the activity `id`

     - Parameters:
     - id: The id of the activity (Number). Example: `"926339514"`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed.\
     It has two return parameters: *Activity*, *AMError*
     - activity: the `Activity` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/activities/926339514*
     */
    func getActivity(withID id: String, storefrontID storeID: String, lang: String? = nil,
                     completion: @escaping (_ activity: AMActivity?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/activities/\(id)"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMActivity.Response.self, from: data),
                        let amError = response.errors?.first {
                        completion(nil, amError)
                    } else {
                        let amError = AMError()
                        if let response = response, let statusCode = response.getStatusCode(),
                            let code = Code(rawValue: String(statusCode * 100)) {
                            amError.status = String(statusCode)
                            amError.code = code
                        }
                        amError.detail = error.localizedDescription
                        completion(nil, amError)
                    }
                } else if let data = data {
                    self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    let response = try? decoder.decode(AMActivity.Response.self, from: data)
                    completion(response?.data?.first, nil)
                } else {
                    completion(nil, nil)
                }
            }
            task.resume()
        }
    }

    /**
     Get several Activity objects based on the `ids` of the activities that you want to get and the Storefront ID of\
     the store

     - Parameters:
     - ids: An id array of the activities. Example: `["956449513", "936419203"]`
     - storeID: The id of the store in two-letter code. Example: `"us"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two\
     return parameters: *[Activity]*, *AMError*
     - activities: the `[Activity]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/catalog/us/activities?ids=956449513,936419203*
     */
    func getMultipleActivities(withIDs ids: [String], storefrontID storeID: String, lang: String? = nil,
                               completion: @escaping (_ activities: [AMActivity]?, _ error: AMError?) -> Void) {
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
            var url = "https://api.music.apple.com/v1/catalog/\(storeID)/activities?ids=\(ids.joined(separator: ","))"
            if let lang = lang {
                url = url + "l=\(lang)"
            }
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMActivity.Response.self, from: data),
                        let amError = response.errors?.first {
                        completion(nil, amError)
                    } else {
                        let amError = AMError()
                        if let response = response, let statusCode = response.getStatusCode(),
                            let code = Code(rawValue: String(statusCode * 100)) {
                            amError.status = String(statusCode)
                            amError.code = code
                        }
                        amError.detail = error.localizedDescription
                        completion(nil, amError)
                    }
                } else if let data = data {
                    self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    let response = try? decoder.decode(AMActivity.Response.self, from: data)
                    completion(response?.data, nil)
                } else {
                    completion(nil, nil)
                }
            }
            task.resume()
        }
    }

}
