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
var dayLimitForCopy = 1
var sampleCount:Int = -1
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
    public func fetchAllHealthData(completion: @escaping (Bool, Error?) -> Swift.Void){
        
        self.getPermissions { (completed, error) in
            guard error == nil else {
                
                let error = NSError(domain:"com.app.error", code:-007, userInfo:[NSLocalizedDescriptionKey:"Error while asking permission"])
                print("Error while asking permission")
                completion(false, error)
                return
            }
            self.fetchedObject = [HKSample]()
            self.fetchedCount = 0;
            let allReadDataType = self.getAllReadDataTypes()
            let startDate = Calendar.current.date(byAdding: .day, value: -dayLimitForCopy, to: Date())!
            let predicte = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: HKQueryOptions.strictStartDate)
            if allReadDataType.count > 0 {
                for hkObjectType in allReadDataType{
                    
                    let query = HKAnchoredObjectQuery.init(type: hkObjectType as! HKSampleType, predicate: predicte, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: { (anchorQueryobject, sample, hkDeletedObject, anchorQuery, error) in
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
                                completion(true, nil)
                            }
                        }
                    })
                    self.store.execute(query);
                }
            }else {
                completion(true, nil)
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
            let managedObjectContext = appDelegate.localPersistentContainer.viewContext
            for sample in self.fetchedObject {
                if(sample.sourceRevision.source.bundleIdentifier == Bundle.main.bundleIdentifier){
                    continue
                }
                let metadata = sample.metadata
                if let metaData = metadata {
                    if let userEntered = (metaData[HKMetadataKeyWasUserEntered] as? Bool), userEntered == true {
                        continue
                    }
                }
                let entity = NSEntityDescription.entity(forEntityName: "DBT_HSSample", in: managedObjectContext)
                let hkSample:DBT_HSSample = NSManagedObject(entity: entity!, insertInto: managedObjectContext) as! DBT_HSSample
                hkSample.identifier = sample.sampleType.identifier
                hkSample.data = sample
            }
            appDelegate.localSaveContext()
            print("\n\n------Copied all the data----\n\n")
        }
    }
    public func getUnknownFetchedObjectsInCoreData() -> [DBT_HSSample]{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("No app delegate")
            return []
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "DBT_HSSample")
        var dbtHKSamples:[DBT_HSSample] = []
        do{
            let managedObjectContext = appDelegate.unknownPersistentContainer.viewContext
            
            let fetchResults:[DBT_HSSample]  = try managedObjectContext.fetch(fetchRequest) as! [DBT_HSSample]
            dbtHKSamples.append(contentsOf: fetchResults)
        }catch let error {
            print("Error while executing the data + \(error)")
        }
        return dbtHKSamples
    }
    public func writeUnknownDatebaseToHealthKit(completion: @escaping (Bool, [Error]) -> Swift.Void){
        self.getPermissions { (completed, error) in
            if let perError = error {
                completion(false,[perError])
                return
            }
            DispatchQueue.main.async {
                let dbtHSSamples = self.getUnknownFetchedObjectsInCoreData()
                //                var hksamples:[HKSample] = []
                var hkSaveErrors:[Error] = []
                guard sampleCount == -1 else {
                    let error = NSError(domain: "self eroror", code: -007, userInfo: [NSLocalizedDescriptionKey : "Already writing going on"])
                    completion(false,[error])
                    return
                }
                sampleCount = dbtHSSamples.count
                if sampleCount>0 {
                for dbtHSSample in dbtHSSamples {
                    var hksample: HKSample? =  dbtHSSample.data as? HKSample
                    let identifier =  dbtHSSample.identifier
                    //                    hksamples.append(hksample)
                    if(identifier == HKQuantityTypeIdentifier.appleExerciseTime.rawValue){
                        sampleCount = sampleCount - 1
                        if(sampleCount == 0){
                             completion(true,hkSaveErrors)
                        }
                        continue
                    }
                    hksample = self.getNewSampleFromSample(oldSample: hksample)
                    
                    if let saveSample = hksample {
                        print("Identifier \(String(describing: identifier)) HKSample \(saveSample)")
                        self.store.save(saveSample, withCompletion: { (saved, error) in
                            if error != nil {
                                hkSaveErrors.append(error!)
                                print("Error while saving the unkown healthData \(String(describing: error))")
                                sampleCount = sampleCount - 1
                                if(sampleCount == 0){
                                    completion(true,hkSaveErrors)
                                }

                            }else {
                                OperationQueue.main.addOperation {
                                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                                        print("No app delegate")
                                        return
                                    }
                                    let managedObjectContext = appDelegate.unknownPersistentContainer.viewContext
                                    managedObjectContext.delete(dbtHSSample)
                                    sampleCount = sampleCount - 1
                                    if(sampleCount == 0){
                                        completion(true,hkSaveErrors)
                                    }
                                }
                            }
                        })
                    }else{
                        sampleCount = sampleCount - 1
                        if(sampleCount == 0){
                            completion(true,hkSaveErrors)
                        }
                    }
                }
                }else{
                completion(true,hkSaveErrors)
                }
            }
        }
    }
    func getNewSampleFromSample(oldSample:HKSample?) -> HKSample?{
        guard oldSample != nil else {
            return nil
        }
        switch oldSample!.sampleType.identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            fallthrough
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            return getNewHKQuantitySampleFromOldHKSample(oldSample:(oldSample as? HKQuantitySample)!)
        case HKWorkoutTypeIdentifier:
            return getWorkoutEventsOldHKSample(oldHKWorkout:(oldSample as? HKWorkout)!)
        case HKCategoryTypeIdentifier.sleepAnalysis.rawValue:
            return getNewHKCategorySampleFromOldHKSample(oldSample: (oldSample as? HKCategorySample)!)
        default:
            return nil
        }
        
    }
    func getNewHKQuantitySampleFromOldHKSample(oldSample: HKQuantitySample) -> HKSample{
        let quantityHKSample = HKQuantitySample(type: oldSample.quantityType, quantity: oldSample.quantity, start: oldSample.startDate, end: oldSample.endDate, device: oldSample.device, metadata: oldSample.metadata)
        return quantityHKSample
    }
    
    func getNewHKCategorySampleFromOldHKSample(oldSample: HKCategorySample) -> HKSample{
        let categoryHKSample = HKCategorySample(type: oldSample.categoryType, value: oldSample.value, start: oldSample.startDate, end: oldSample.endDate, device: oldSample.device, metadata: oldSample.metadata)
        return categoryHKSample
    }
    
    func getWorkoutEventsOldHKSample(oldHKWorkout: HKWorkout) -> HKSample {
        var workout:HKWorkout?
        if oldHKWorkout.totalFlightsClimbed != nil{
            workout = HKWorkout(activityType: oldHKWorkout.workoutActivityType, start: oldHKWorkout.startDate, end: oldHKWorkout.endDate, workoutEvents: oldHKWorkout.workoutEvents, totalEnergyBurned: oldHKWorkout.totalEnergyBurned, totalDistance: oldHKWorkout.totalDistance, totalFlightsClimbed: oldHKWorkout.totalFlightsClimbed, device: oldHKWorkout.device, metadata: oldHKWorkout.metadata)
        }else{
//            if (oldHKWorkout.totalSwimmingStrokeCount != nil) {
//              workout = HKWorkout(
            //        }else{
            workout = HKWorkout(activityType: oldHKWorkout.workoutActivityType, start: oldHKWorkout.startDate, end: oldHKWorkout.endDate, workoutEvents: oldHKWorkout.workoutEvents, totalEnergyBurned: oldHKWorkout.totalEnergyBurned, totalDistance: oldHKWorkout.totalDistance, device: oldHKWorkout.device, metadata:oldHKWorkout.metadata)
        }
        return workout!;
    }
}
