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
import SSZipArchive
import NVActivityIndicatorView

class ViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var copyDayLimitTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileUtitlity.getDocumentsDirectory())
        print(FileUtitlity.getApplicationSupportDirectory())
        copyDayLimitTextField.text = "\(dayLimitForCopy)"
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //MARK: Actions
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        //Your
        let folderPath = FileUtitlity.getApplicationSupportDirectoryDatabase()
        let folderURL = URL(fileURLWithPath: folderPath)
        
        if(FileManager.default.fileExists(atPath: folderURL.path)){
            do{
                let zipFilePath = FileUtitlity.getDocumentryZipFilePath()
                if(FileManager.default.fileExists(atPath: zipFilePath)){
                    try FileManager.default.removeItem(at: URL.init(fileURLWithPath: zipFilePath))
                }
                SSZipArchive.createZipFile(atPath: zipFilePath, withContentsOfDirectory: folderPath, keepParentDirectory: true, withPassword: zipPassword)
                
                let activityVC = UIActivityViewController(activityItems: [URL.init(fileURLWithPath: zipFilePath)], applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }catch let error {
                print("error while loading the zip file \(error)")
            }
            
        }else{
            FileUtitlity.showSimpleAlert("No database", message: "You can generate the database by clicking \"Copy all HealthKit data to local\" ", viewController: self)
        }
        
    }
    
    @IBAction func copyButtonClicked(_ sender: Any){
        self.view.endEditing(true)
        let text = copyDayLimitTextField.text ?? ""
        let dayLimit = Int(text) ?? 1
        guard dayLimit < 32,dayLimit > 0 else {
            FileUtitlity.showSimpleAlert("Wrong copy day limit", message: "Please enter valid number days to copy from Healthkit data. It should be in the range of >0 and <=31", viewController: self)
            return
        }
        startActivitiyIndicator(message: "Copying from Health....")
        OperationQueue.main.addOperation {
            dayLimitForCopy = dayLimit
            //Your
            let folderPath = FileUtitlity.getApplicationSupportDirectoryDatabase()
            let folderURL = URL(fileURLWithPath: folderPath)
            do{
                if(FileManager.default.fileExists(atPath: folderURL.path)){
                    try FileManager.default.removeItem(at: folderURL)
                    self.clearPerisitentStores()
                }
            }catch let error {
                print("Error while removing the SQliteFile \(error)")
                self.stopAcitivityIndicator()
            }
            
            HealthKtiManager.shared.fetchAllHealthData{ (completed, error) in
                OperationQueue.main.addOperation {
                    self.stopAcitivityIndicator()
                    if error != nil {
                        FileUtitlity.showSimpleAlert("Error!", message: error?.localizedDescription, viewController: self)
                    }else{
                        FileUtitlity.showSimpleAlert("Info!", message: "All Healthkit data copied to app database. Now ready to share", viewController: self)
                    }
                }
            }
        }
    }
    
    
    @IBAction func copyFromClipboard(_ sender: Any){
        
        var copied  = false
        startActivitiyIndicator(message: "Copying from Clipboard in progress....")
        OperationQueue.main.addOperation {
            
            if UIPasteboard.general.contains(pasteboardTypes: ["public.zip-archive"]) {
                
                let fileData = UIPasteboard.general.value(forPasteboardType: "public.zip-archive")
                
                if let zipFileData:Data = fileData as? Data {
                    
                    let pasteSqliteURLPath = FileUtitlity.getDocumentryZipFilePath()
                    
                    if( FileManager.default.fileExists(atPath: pasteSqliteURLPath)){
                        do {
                            try FileManager.default.removeItem(atPath: pasteSqliteURLPath)
                        } catch let error {
                            print("Error while removing the file \(error)")
                        }
                    }
                    do {
                        
                        try zipFileData.write(to: URL.init(fileURLWithPath: pasteSqliteURLPath) )
                        try SSZipArchive.unzipFile(atPath: pasteSqliteURLPath, toDestination: FileUtitlity.getDocumentsDirectory(), overwrite: true, password: zipPassword)
                        try FileManager.default.removeItem(atPath: pasteSqliteURLPath)
                        copied = true
                    } catch let error{
                        print("Error while writing the data \(error)")
                        FileUtitlity.showSimpleAlert("Error", message: "Error while writing the data \(error)", viewController: self)
                    }
                    
                }
            }
            
            if !copied {
                FileUtitlity.showSimpleAlert("Zip file error", message: "Clipboard data is not a zip file", viewController: self)
            }else{
                self.clearPerisitentStores()
                FileUtitlity.showSimpleAlert("Success!", message: "Successfully copied from clipboard", viewController: self)
            }
            self.stopAcitivityIndicator()
        }
        
    }
    
    @IBAction func copyDataFromShare(_ sender: Any){
        startActivitiyIndicator(message: "Copying from shared space....")
        OperationQueue.main.addOperation {
            let unknownZipPath = FileUtitlity.getGroupShareUnknowZipPath()
            let localDocuZipFile = FileUtitlity.getDocumentryNewZipFilePath()
            let documentDirectoryDatabasePath = FileUtitlity.getDocumentsDirectoryDatabse()
            do{
                if( FileManager.default.fileExists(atPath: unknownZipPath )){
                    if( FileManager.default.fileExists(atPath: localDocuZipFile)){
                        
                        try FileManager.default.removeItem(atPath: localDocuZipFile)
                        
                    }
                    try FileManager.default.copyItem(atPath: unknownZipPath, toPath: localDocuZipFile)
                    if( FileManager.default.fileExists(atPath: documentDirectoryDatabasePath)){
                        
                        try FileManager.default.removeItem(atPath: documentDirectoryDatabasePath)
                        
                    }
                    try SSZipArchive.unzipFile(atPath: localDocuZipFile, toDestination: FileUtitlity.getDocumentsDirectory(), overwrite: true, password: zipPassword)
                    try FileManager.default.removeItem(atPath: localDocuZipFile)
                }else{
                    FileUtitlity.showSimpleAlert("Error!", message: "No data available in shared location", viewController: self)
                }
            }catch let error {
                print("Error while executing filemanager : \(error)")
            }
            self.stopAcitivityIndicator()
        }
    }
    
    @IBAction func writeDataToHealthKit(_ sender: Any){
        
        if( FileManager.default.fileExists(atPath: FileUtitlity.getDocumentsDirectorySqlitePath())){
            self.startActivitiyIndicator(message: "Writing data to Health.....")
            OperationQueue.main.addOperation {
                HealthKtiManager.shared.writeUnknownDatebaseToHealthKit{ (completed, errors) in
                    do{
                        if errors.count == 0 {
                            try FileManager.default.removeItem(atPath: FileUtitlity.getDocumentsDirectoryDatabse())
                            FileUtitlity.showSimpleAlert("Success!", message: "All data from local written to AHK and local get cleared", viewController: self)
                        }else{
                            FileUtitlity.showSimpleAlert("Error!", message: "Error while writing the data to AHK: \(errors)", viewController: self)
                        }
                    }catch let error {
                        FileUtitlity.showSimpleAlert("Error!", message: "Error while removing the zip file: \(error)", viewController: self)
                    }
                    self.stopAcitivityIndicator()
                }
            }
        }else{
            FileUtitlity.showSimpleAlert("Error!", message: "No new database available", viewController: self)
        }
    }
    
    func clearPerisitentStores(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("No app delegate")
            return
        }
        let newAppDelegate = AppDelegate()
        appDelegate.localPersistentContainer = newAppDelegate.localPersistentContainer
        appDelegate.unknownPersistentContainer = newAppDelegate.unknownPersistentContainer
    }
    
    //MARK: Activity indicatore views
    func startActivitiyIndicator(message:String) {
        
        startAnimating(CGSize(width:self.view.bounds.size.width,height:50),
                       message:message)
    }
    
    func stopAcitivityIndicator() {
        stopAnimating()
    }
}

