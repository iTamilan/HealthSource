//
//  ViewController.swift
//  HealthSource
//
//  Created by Tamilarasu on 25/09/17.
//  Copyright © 2017 Tamilarasu Ponnusamy. All rights reserved.
//

import UIKit
import CoreData
import HealthKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        HealthKtiManager.shared.fetchAllHealthData()
//        HealthKtiManager.shared.unwrapTheObjects()
        self.fetcTheAlltheData()
    }
    func fetcTheAlltheData() {
        guard let appDelegate = UIApplication.shared.delegate as?AppDelegate else {
            print("No App delegate")
            return
        }
        let manageObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DBT_HSSample")
        do {
            let results =  try manageObjectContext.fetch(fetchRequest)
            for managedObject in results {
                let hksample:DBT_HSSample = managedObject as! DBT_HSSample
                let sample: HKSample? = hksample.data as? HKSample
                print("Sample identifier \(String(describing: hksample.identifier)) Sample \(String(describing: sample))")
                sample?.uuid = NSUUID.init()
                sample?.sourceRevision
                
            }
            print(results)
        } catch {
            print("Exception oocured while fetching the data")
        }
        
    }
}

