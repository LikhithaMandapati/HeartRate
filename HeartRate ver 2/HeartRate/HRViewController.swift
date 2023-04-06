//
//  HRViewController.swift
//  HeartRate
//
//  Created by student on 4/2/23.
//

import UIKit

class HRViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var hr = [[String: Any]]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hrCell", for: indexPath)
        
        let valueLabel = cell.viewWithTag(3) as! UILabel
        let dateLabel = cell.viewWithTag(4) as! UILabel
        
        let hrData = hr[indexPath.row]
        let value = hrData["value"] as? String ?? ""
        let date = hrData["date"] as? String ?? ""
    
        valueLabel.text = String(value)
        dateLabel.text = date
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "      Value                           Date"
        }
        return nil
    }

    
    @IBAction func exportCSVButtonTapped(_ sender: UIButton) {
        
        let fileName = "hr_data.csv"
                let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
                // doc dirt how to store and see
                var csvText = "Value, Date\n"
                
                for data in hr {
                    let value = data["value"] as? String ?? ""
                    let date = data["date"] as? String ?? ""
                    let newLine = "\(value),\(date)\n"
                    csvText.append(contentsOf: newLine)
                }
                
                do {
                    try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                    let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                    present(vc, animated: true, completion: nil)
                } catch {
                    print("Failed to create CSV file: \(error.localizedDescription)")
                }
    }
    
}
