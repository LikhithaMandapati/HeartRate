//
//  ValuesViewController.swift
//  HeartRate
//
//  Created by student on 4/2/23.
//

import UIKit

class ValuesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var hrv = [[String: Any]]()
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hrv.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hrvCell", for: indexPath)
        
        let valueLabel = cell.viewWithTag(1) as! UILabel
        let dateLabel = cell.viewWithTag(2) as! UILabel
        
        let hrvData = hrv[indexPath.row]
        let value = hrvData["value"] as? Double ?? 0.0
        let date = hrvData["date"] as? Date ?? Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        
        valueLabel.text = String(format: "%.2f", value)
        dateLabel.text = dateString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "        Value                           Date"
        }
        return nil
    }

    
    @IBAction func exportCSVButtonTapped(_ sender: UIButton) {
        
        let fileName = "hrv_data.csv"
                let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
                // doc dirt how to store and see
                var csvText = "Value, Date\n"
                
                for data in hrv {
                    let value = data["value"] as? Double ?? 0.0
                    let date = data["date"] as? Date ?? Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let dateString = dateFormatter.string(from: date)
                    let newLine = "\(value),\(dateString)\n"
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
