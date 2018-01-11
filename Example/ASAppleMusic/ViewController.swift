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
        var request = URLRequest(url: URL(string: url)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do{
                    let result = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]

                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = true
                        self.responseTextView.text = result.description
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = true
                        self.responseTextView.text = "Error: JSON serialization failed"
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.responseTextView.text = "Error: Data empty"
                }
            }
            }.resume()
    }

    @IBAction func cleanTextTouched(sender: UIButton) {
        responseTextView.text = "Press down to get data!"
    }

    @IBAction func makeRequestTouched(sender: UIButton) {
        if let text = urlTextField.text, text.isEmpty {
            let alert = UIAlertController(title: "Empty field", message: "Write some Apple Music API URL", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        } else {
            activityIndicator.isHidden = false

            var request = URLRequest(url: URL(string: "https://us-central1-party-play-86273.cloudfunctions.net/getToken")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15.0)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let dict = ["kid": "AEMNS29Z35", "tid": "845N682JEC"]

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                request.httpBody = jsonData

                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let data = data {
                        do{
                            let result = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]

                            DispatchQueue.main.async {
                                if let token = result["token"] as? String {
                                    self.callAppleMusic(token: token, url: self.urlTextField.text!)
                                }
                            }
                        } catch {
                            DispatchQueue.main.async {
                                self.activityIndicator.isHidden = true
                                self.responseTextView.text = "Error: JSON serialization failed"
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.activityIndicator.isHidden = true
                            self.responseTextView.text = "Error: Data empty"
                        }
                    }
                    }.resume()
            } catch {
                print("Catch JSON")
            }
        }
    }
}
