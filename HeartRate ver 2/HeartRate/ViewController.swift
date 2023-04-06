//
//  ViewController.swift
//  HeartRate
//
//  Created by Likhitha Mandapati on 1/9/23.
//

import UIKit
import WatchConnectivity
//import FirebaseDatabase
import HealthKit


class ViewController: UIViewController {
  
    var session: WCSession?
    var refreshDate = ""
    var hrv = [[String: Any]]()
    var hr = [[String: Any]]()
    let healthStore = HKHealthStore()
    var timer = Timer()
    private var heartRateVariability = HKUnit(from: "count/min")
    
  
    
  override func viewDidLoad() {
      super.viewDidLoad()
      authorizeHealthKit()
      self.configureWatchKitSession()
      fetchHealthData()
  }
    
    // authorization
    func authorizeHealthKit(){
        let writableTypes: Set<HKSampleType> = [
                HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!
            ]
            let readableTypes: Set<HKSampleType> = [
                HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!
            ]
       healthStore.requestAuthorization(toShare: writableTypes, read: readableTypes) { (chk, error) in
            if (chk) {
                print("permission granted")
            }
        }
        
    }
    

    func fetchHealthData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mm:ss"
        self.refreshDate = formatter.string(from: Date())
        self.latestHRV()
    }
    
  
  func configureWatchKitSession() {
    if WCSession.isSupported() {
      session = WCSession.default
      session?.delegate = self
      session?.activate()
    }
  }
    
    // collect hrv from health app
    func latestHRV() {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            return
        }
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (sample, result, error) in
            guard error == nil else{
                return
            }
            let data = result as! [HKQuantitySample]
            for d in data {
                let unit = HKUnit(from: "ms")
                let value = d.quantity.doubleValue(for: unit)
                let date = d.startDate
                //print("HRV value: \(value), Date: \(date)")
                let hrvDict: [String: Any] = ["value": value, "date": date]
                self.hrv.append(hrvDict)
            }
            DispatchQueue.main.async() {
            }
        }
        healthStore.execute(query)
    }
    
    
    @IBAction func hrButton(_ sender: Any) {
        performSegue(withIdentifier: "seg_main_hr", sender: self)
    }
    
    @IBAction func hrvButton(_ sender: Any) {
        performSegue(withIdentifier: "seg_main_hrv", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "seg_main_hr" {
                   if let destinationVC = segue.destination as? HRViewController {
                       destinationVC.hr = self.hr
                   }
               } else if segue.identifier == "seg_main_hrv" {
                   if let destinationVC = segue.destination as? ValuesViewController {
                       destinationVC.hrv = self.hrv
                   }
               }
           }
}

// WCSession delegate functions
extension ViewController: WCSessionDelegate {
  
  func sessionDidBecomeInactive(_ session: WCSession) {
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
  }
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    //print("received message: \(message)")
    DispatchQueue.main.async { //6
      if let value = message["watch"] as? [[String: Any]] {
          self.hr = value
      }
    }
  }
}

