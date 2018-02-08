//
//  HSPersistentStore.swift
//  HealthSource
//
//  Created by Tamilarasu on 11/02/18.
//  Copyright © 2018 Tamilarasu. All rights reserved.
//

import Foundation
import CoreData
let HSModelName = "HealthSource"
class HSPersistentStore {
    // MARK: - Core Data stack
    static var localPersistent = HSPersistentStore(modelName: HSModelName, filePath: FileUtitlity.getApplicationSupportDirectorySqlitePath())
    static var unknownPersistent = HSPersistentStore(modelName: HSModelName, filePath: FileUtitlity.getDocumentsDirectorySqlitePath())
    
    static func reinitializePersistentStore(){
        reinitializeLocalPersistentStore()
        reinitializeUnknownPersistentStore()
    }
    
    static func reinitializeLocalPersistentStore(){
        localPersistent = HSPersistentStore(modelName: HSModelName, filePath: FileUtitlity.getApplicationSupportDirectorySqlitePath())
    }
    
    static func reinitializeUnknownPersistentStore(){
        unknownPersistent = HSPersistentStore(modelName: HSModelName, filePath: FileUtitlity.getDocumentsDirectorySqlitePath())
    }
    
    
    private let modelName:String
    private let filePath:String
    
    init(modelName:String,filePath:String) {
        self.modelName = modelName
        self.filePath = filePath
    }
    
    lazy var container: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let description = NSPersistentStoreDescription(url: URL(fileURLWithPath: self.filePath))
        
        let container = NSPersistentContainer(name: self.modelName)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("HS Persistentstore Load Error:\(self.modelName):\(self.filePath) Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("HS Persistentstore Save Error:\(self.modelName):\(self.filePath) Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
import HealthKit
extension HSPersistentStore {
    public func saveHKSamples(_ hkSamples:[HKSample]){
        DispatchQueue.main.async {
        
            let managedObjectContext = self.container.viewContext
            for sample in hkSamples {
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
            self.saveContext()
            print("\n\n------SoredHealth data----\n\n")
        }
    }
    
    public func getDBTHKSamples() -> [DBT_HSSample]{
       
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "DBT_HSSample")
        var dbtHKSamples:[DBT_HSSample] = []
        do{
            let managedObjectContext = container.viewContext
            
            let fetchResults:[DBT_HSSample]  = try managedObjectContext.fetch(fetchRequest) as! [DBT_HSSample]
            dbtHKSamples.append(contentsOf: fetchResults)
        }catch let error {
            print("Error while executing the data + \(error)")
        }
        return dbtHKSamples
    }
    
}
