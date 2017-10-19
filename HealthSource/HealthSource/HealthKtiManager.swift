//
//  HealthKtiManager.swift
//  HealthSource
//
//  Created by Tamilarasu on 01/10/17.
//  Copyright © 2017 Tamilarasu Ponnusamy. All rights reserved.
//

import UIKit
import HealthKit
import CoreData
class HealthKtiManager: NSObject {
    public static let shared = HealthKtiManager()
    let store:HKHealthStore
    let operationQueue:OperationQueue
    var fetchedObject = [HKSample]()
    var fetchedCount = 0;
    override init() {
        self.store = HKHealthStore.init()
        self.operationQueue = OperationQueue.init()
        self.operationQueue.maxConcurrentOperationCount = 1
    }
    public func getPermissions(completion: @escaping (Bool, Error?) -> Swift.Void){
        self.store .requestAuthorization(toShare: Set.init(self.getAllWriteDataTypes()) as? Set<HKSampleType> , read: Set.init(self.getAllReadDataTypes())) { (completed, error) in
            print("HealthKit Permission Granded \(completed)")
            if let errorThere = error {
                print("HealthKit Permission Error \(errorThere)");
            }
            completion(completed,error)
        }
    }
    public func fetchAllHealthData(){
        
        self.getPermissions { (completed, error) in
            guard error == nil else {
                print("Error while asking permission")
                return
            }
            self.fetchedObject = [HKSample]()
            self.fetchedCount = 0;
            let allReadDataType = self.getAllReadDataTypes()
            for hkObjectType in allReadDataType{
                
                let query = HKAnchoredObjectQuery.init(type: hkObjectType as! HKSampleType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: { (anchorQueryobject, sample, hkDeletedObject, anchorQuery, error) in
                    self.operationQueue.addOperation {
                        self.fetchedCount += 1;
                        print("Current Fetched data type \(hkObjectType.identifier)")
                        if let samples = sample {
                            self.fetchedObject.append(contentsOf: samples)
                            print("Current Fetched data type object Count  \(samples.count)")
                        }
                        
                        print("Total Fetched count \(self.fetchedCount)");
                        print("Total Fetched object count \(self.fetchedObject.count)");
                        print("-------------------------------")
                        print("-------------------------------")
                        if self.fetchedCount == allReadDataType.count {
                            print("Total Fetched data types \(self.fetchedCount)");
                            print("Total fetched objects \(self.fetchedObject.count)");
                            self.saveAllFetchedObjectsInCoreData()
                        }
                    }
                })
                self.store.execute(query);
            }
        }
    }
    public func unwrapTheObjects(){
//        UserDefaults.standard.set(dataObject, forKey: "FetchedObjects");
        let data:Any? = UserDefaults.standard.object(forKey: "FetchedObjects")
        if data is Data {
            let dataObjects = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
            print(dataObjects ?? "Nothing")
        }
    }
    public func saveAllFetchedObjectsInCoreData(){
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                print("No app delegate")
                return
            }
            let managedObjectContext = appDelegate.persistentContainer.viewContext
            for sample in self.fetchedObject {
                let entity = NSEntityDescription.entity(forEntityName: "DBT_HSSample", in: managedObjectContext)
                let hkSample:DBT_HSSample = NSManagedObject(entity: entity!, insertInto: managedObjectContext) as! DBT_HSSample
                hkSample.identifier = sample.sampleType.identifier
                hkSample.data = sample
            }
            appDelegate.saveContext()
        }
    }
}
