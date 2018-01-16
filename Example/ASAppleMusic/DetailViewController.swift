//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import UIKit
import ASAppleMusic

extension String {
    func clean(characters oldChars: [String], with newChars: [String]) -> String {
        var i = 0
        var resultString = self

        oldChars.forEach { oldChar in
            resultString = resultString.replacingOccurrences(of: oldChar, with: newChars[i])
            i += 1
        }

        return resultString
    }
}

class DetailViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var statusLabel: UILabel!

    var params: [String:String]!
    var function: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        ASAppleMusic.shared.makeCall(ofType: CallType(rawValue: function)!, withParams: params) { result, error in
            self.activityIndicator.isHidden = true

            if let result = result {
                self.statusLabel.text = "Response: OK"
                self.statusLabel.textColor = .green
                self.responseTextView.textColor = .black
                if let descArray = result as? [AnyObject] {
                    var description = ""
                    descArray.forEach { object in
                        if let desc = object.description {
                            description = "\(description)\n\n\(desc)"
                        }
                    }
                    self.responseTextView.text = description.clean(characters: ["\\/", "\\\""], with: ["/", "\""])
                } else {
                    self.responseTextView.text = result.description.clean(characters: ["\\/", "\\\""], with: ["/", "\""])
                }
            } else {
                self.statusLabel.text = "Response: ERROR"
                self.statusLabel.textColor = .red
                self.responseTextView.textColor = .red
                if let error = error, let title = error.title,
                    let status = error.status {
                    var errorString = "\(title) (\(status))"

                    if let detail = error.detail {
                        errorString = "\(errorString)\n\(detail)"
                    }

                    self.responseTextView.text = errorString
                }
            }
        }
    }

}
