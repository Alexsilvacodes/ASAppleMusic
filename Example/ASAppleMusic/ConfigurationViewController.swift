//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import UIKit

class ConfigurationViewController: UIViewController {

    @IBOutlet weak var confTableView: UITableView!
    @IBOutlet weak var pickerViewContainer: UIView!
    @IBOutlet weak var darkContainer: UIView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var requestPickerView: UIPickerView!
    @IBOutlet weak var requestLabel: UILabel!
    @IBOutlet weak var makeRequestButton: UIButton!

    var subsections: [String:Any]!
    var selectedRequest: [String:Any] = [:]
    var params: [String:String] = [:]
    var nonOptionalParams: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRequest = UITapGestureRecognizer(target: self, action: #selector(requestTapped))
        requestLabel.addGestureRecognizer(tapRequest)
        let tapBackground = UITapGestureRecognizer(target: self, action: #selector(removeKeyboard))
        view.addGestureRecognizer(tapBackground)

        confTableView.tableFooterView = UIView(frame: .zero)
    }

    func selectRequest(byRow row: Int) {
        nonOptionalParams = []
        params = [:]

        requestLabel.text = Array(subsections.keys)[row]

        let key = Array(subsections.keys)[row]
        selectedRequest = subsections[key] as! [String:Any]
        var i = 0
        let paramsRequest = selectedRequest["params"] as! [String:Any]
        paramsRequest.values.forEach {
            let param = $0 as! [String:Any]
            if let optional = param["optional"] as? Bool, !optional {
                let key = Array(paramsRequest.keys)[i]
                nonOptionalParams.append(key)
            }
            i += 1
        }

        makeRequestButton.isEnabled = true
        makeRequestButton.backgroundColor = .darkGray
        confTableView.isHidden = false
        confTableView.reloadData()
    }

    @objc func removeKeyboard() {
        view.endEditing(false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConfigurationToDetail" {
            if let vc = segue.destination as? DetailViewController {
                vc.title = Array(subsections.keys)[requestPickerView.selectedRow(inComponent: 0)]
                vc.params = params
                vc.function = selectedRequest["function"] as! String
            }
        }
    }

    @objc func requestTapped(sender: UITapGestureRecognizer) {
        darkContainer.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.pickerViewContainer.alpha = 1.0
        }
    }

    @IBAction func doneTouched(sender: UIBarButtonItem) {
        darkContainer.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.pickerViewContainer.alpha = 0.0
        }

        selectRequest(byRow: requestPickerView.selectedRow(inComponent: 0))
    }

    @IBAction func makeRequestTouched(sender: UIButton) {
        var missingParam = false
        nonOptionalParams.forEach { nonOptParam in
            missingParam = !params.keys.contains(nonOptParam)
        }
        if params.keys.count >= nonOptionalParams.count && !missingParam {
            performSegue(withIdentifier: "ConfigurationToDetail", sender: sender)
        } else {
            let alert = UIAlertController(title: "Empty mandatory fields", message: "Fill all the non-optional fields to make the request", preferredStyle: .alert)
            let accept = UIAlertAction(title: "Accept", style: .cancel, handler: nil)
            alert.addAction(accept)
            present(alert, animated: true, completion: nil)
        }
    }

}

extension ConfigurationViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        let paramsRequest = selectedRequest["params"] as! [String:Any]
        let key = Array(paramsRequest.keys)[textField.tag]

        if let text = textField.text, !text.isEmpty {
            params[key] = textField.text
        } else {
            params.removeValue(forKey: key)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        removeKeyboard()

        return true
    }

}

extension ConfigurationViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return subsections.keys.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(subsections.keys)[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        requestLabel.text = Array(subsections.keys)[row]

        selectRequest(byRow: row)
    }

}

extension ConfigurationViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let paramsRequest = selectedRequest["params"] as? [String:Any] {
            return paramsRequest.keys.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfCell", for: indexPath) as! ConfigurationTableViewCell


        let paramsRequest = selectedRequest["params"] as! [String:Any]
        let key = Array(paramsRequest.keys)[indexPath.row]
        let param = paramsRequest[key] as! [String:Any]
        cell.titleLabel.text = param["name"] as? String
        var placeholder = param["placeholder"] as! String
        if let optional = param["optional"] as? Bool, optional {
            placeholder = "\(placeholder) (Optional)"
        }
        cell.valueTextField.placeholder = placeholder
        cell.valueTextField.text = ""
        cell.valueTextField.tag = indexPath.row
        cell.valueTextField.delegate = self

        return cell
    }

}
