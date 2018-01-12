//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import UIKit
import ASAppleMusic

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
                if let descArray = result as? [AnyObject] {
                    var description = ""
                    descArray.forEach { object in
                        if let desc = object.description {
                            description = "\(description)\n\n\(desc)"
                        }
                    }
                    self.responseTextView.text = description
                } else {
                    self.responseTextView.text = result.description
                }
            } else {
                self.statusLabel.text = "Response: ERROR"
                self.statusLabel.textColor = .red
                self.responseTextView.text = ""
            }
        }
    }

}
