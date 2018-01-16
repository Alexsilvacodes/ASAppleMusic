//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var sectionTableView: UITableView!

    var sections: [String:Any] = [:]
    var subsectionSelected: [String:Any] = [:]
    var titleSelected: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        sectionTableView.tableFooterView = UIView(frame: .zero)

        if let path = Bundle.main.path(forResource: "Sections", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String:Any] {
            sections = dict
        } else {
            sections = [:]

            sectionTableView.isHidden = true
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainToConfiguration" {
            if let vc = segue.destination as? ConfigurationViewController {
                vc.subsections = subsectionSelected
                vc.title = titleSelected
            }
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.keys.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell", for: indexPath)

        let key = Array(sections.keys)[indexPath.row]
        cell.textLabel?.text = key

        if let sectionDict = sections[key] as? [String:Any], sectionDict.isEmpty {
            cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 17.0)
            cell.textLabel?.textColor = .lightGray
            cell.accessoryType = .none
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17.0)
            cell.textLabel?.textColor = .black
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let key = Array(sections.keys)[indexPath.row]
        subsectionSelected = sections[key] as! [String:Any]
        titleSelected = key

        if !subsectionSelected.isEmpty {
            performSegue(withIdentifier: "MainToConfiguration", sender: self)
        }
    }
}
