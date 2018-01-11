//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import UIKit
import ASAppleMusic

class ViewController: UIViewController {

    @IBOutlet weak var makeRequestButton: UIButton!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func callAppleMusic(token: String, url: String) {

    }

    @IBAction func cleanTextTouched(sender: UIButton) {
        responseTextView.text = "Press down to get data!"
    }

    @IBAction func makeRequestTouched(sender: UIButton) {
        activityIndicator.isHidden = false

        ASAppleMusic.shared.getStorefront(withID: "us") { storefront, error in
            if let storefront = storefront {
                print(storefront.name)
            }
        }
    }
}
