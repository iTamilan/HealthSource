//
//  HealthKtiManager.swift
//  HealthSource
//
//  Created by Tamilarasu on 01/10/17.
//  Copyright © 2017 Tamilarasu. All rights reserved.
//

import UIKit
import HealthKit
import CoreData
fileprivate var sampleCount:Int = -1
class HealthKtiManager: NSObject {
    public static let shared = HealthKtiManager()
    let store:HKHealthStore
    let operationQueue:OperationQueue
    var fetchedObject = [HKSample]()
    var fetchedCount = -1;
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
    public func fetchAllHealthData(completion: @escaping (Bool, [HKSample]?, Error?) -> Swift.Void){
        let startDate = dateRange.fromDate
        let endDate = dateRange.toDate
//        let anchorQueryDict = HSUserDefaults.shared.getHKAnchorQueryDictionary()
        fetchAllHealthData(startDate: startDate, endDate: endDate, anchorQueryDict: nil) { (success, queryDict,hksamples, error) in
            completion(success,hksamples,error)
        }
        
    }
    public func fetchAllHealthData(startDate:Date?,endDate:Date?, anchorQueryDict:HSQueryAnchorDictionay?, completion: @escaping (Bool, HSQueryAnchorDictionay?, [HKSample]?, Error?) -> Swift.Void){
        self.getPermissions { (completed, error) in
            guard error == nil else {
                
                let error = NSError(domain:"com.app.error", code:-007, userInfo:[NSLocalizedDescriptionKey:"Error while asking permission"])
                print("Error while asking permission")
                completion(false, nil , nil,error)
                return
            }
            guard self.fetchedCount == -1 else{
                let error = NSError(domain:"com.app.error.inprogress", code:-008, userInfo:[NSLocalizedDescriptionKey:"Already data fetching"])
                print("AHK Fetching already in progress")
                completion(false, nil, nil, error)
                return
            }
            self.fetchedObject = [HKSample]()
            self.fetchedCount = 0;
            let allReadDataType = self.getAllReadDataTypes()
            let predicte = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictStartDate)
            var updateAnchorQueryDict = anchorQueryDict
            if allReadDataType.count > 0 {
                for hkObjectType in allReadDataType{
                    
                    let query = HKAnchoredObjectQuery.init(type: hkObjectType as! HKSampleType, predicate: predicte, anchor: updateAnchorQueryDict?[hkObjectType.identifier], limit: HKObjectQueryNoLimit, resultsHandler: { (anchorQueryobject, sample, hkDeletedObject, anchorQuery, error) in
                        self.operationQueue.addOperation {
                            self.fetchedCount += 1;
                            print("Current Fetched data type \(hkObjectType.identifier)")
                            if let samples = sample {
                                self.fetchedObject.append(contentsOf: samples)
                                print("Current Fetched data type object Count  \(samples.count)")
                            }
                            if error == nil {
                                updateAnchorQueryDict?[hkObjectType.identifier] = anchorQuery
                            }
                            print("Total Fetched count \(self.fetchedCount)");
                            print("Total Fetched object count \(self.fetchedObject.count)");
                            print("-------------------------------")
                            print("-------------------------------")
                            if self.fetchedCount == allReadDataType.count {
                                print("Total Fetched data types \(self.fetchedCount)");
                                print("Total fetched objects \(self.fetchedObject.count)");
                                self.fetchedCount = -1
                                completion(true, updateAnchorQueryDict,self.fetchedObject,nil)
                            }
                        }
                    })
                    self.store.execute(query);
                }
            }else {
                self.fetchedCount = -1
                completion(true,updateAnchorQueryDict,nil,nil)
            }
        }
    }
   
    public func writeToHealthKit(hkSamples:[HKSample],completion: @escaping (Bool, [Error]) -> Swift.Void){
        self.getPermissions { (completed, error) in
            if let perError = error {
                completion(false,[perError])
                return
            }
            DispatchQueue.main.async {
               
                var hkSaveErrors:[Error] = []
                guard sampleCount == -1 else {
                    let error = NSError(domain: "self eroror", code: -007, userInfo: [NSLocalizedDescriptionKey : "Already writing going on"])
                    completion(false,[error])
                    return
                }
                sampleCount = hkSamples.count
                if sampleCount>0 {
                    for hkSample in hkSamples {
                    
                    let identifier =  hkSample.sampleType.identifier
                    
                    if(identifier == HKQuantityTypeIdentifier.appleExerciseTime.rawValue){
                        sampleCount = sampleCount - 1
                        if(sampleCount == 0){
                            sampleCount = -1
                             completion(true,hkSaveErrors)
                        }
                        continue
                    }
                    
                    if let saveSample = self.getNewSampleFromSample(oldSample: hkSample) {
                        print("Identifier \(String(describing: identifier)) HKSample \(saveSample)")
                        self.store.save(saveSample, withCompletion: { (saved, error) in
                            if error != nil {
                                hkSaveErrors.append(error!)
                                print("Error while saving the unkown healthData \(String(describing: error))")
                                sampleCount = sampleCount - 1
                                if(sampleCount == 0){
                                    sampleCount = -1
                                    completion(true,hkSaveErrors)
                                }

                            }else {
                                OperationQueue.main.addOperation {
                                   
                                    sampleCount = sampleCount - 1
                                    if(sampleCount == 0){
                                        sampleCount = -1
                                        completion(true,hkSaveErrors)
                                    }
                                }
                            }
                        })
                    }else{
                        sampleCount = sampleCount - 1
                        if(sampleCount == 0){
                            sampleCount = -1
                            completion(true,hkSaveErrors)
                        }
                    }
                }
                }else{
                    sampleCount = -1
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
