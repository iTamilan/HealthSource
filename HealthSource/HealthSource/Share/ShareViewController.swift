//
//  ShareViewController.swift
//  HealthSource
//
//  Created by Tamilarasu on 10/02/18.
//  Copyright © 2018 Tamilarasu. All rights reserved.
//

import UIKit
import SSZipArchive
import HealthKit

fileprivate enum Row{
    case range
    case readStoreAction
    case copyFromClipbord
    case copyToClipbord
    case copyFromShare
    case write
    case share
    case clearAll
    
    func title() -> String {
        switch self {
        case .range:
            return "Range"
        case .readStoreAction:
            return "Read & store locally"
        case .copyToClipbord:
            return "Copy to Clipboard"
        case .copyFromClipbord:
            return "Copy from Clipboard"
        case .copyFromShare:
            return "Import from Share extension"
        case .share:
            return "Export"
        case .clearAll:
            return "Clear all local data & Relaunch"
        case .write:
            return "Write to HealthKit"
        }
    }
}

fileprivate enum Section {
    case readStore
    case copy
    case write
    case share
    case clearAll
    func headerTitle() -> String {
        switch self {
        case .readStore:
            return "Read HealthKit data & Store"
        case .copy:
            return "Import"
        case .write:
            return "Write"
        case .share:
            return "Export"
        case .clearAll:
            return ""
        }
    }
    
    func footerTitle() -> String {
        switch self {
        case .readStore:
            return "This will read the data in above range from HealthKit and stores them in locally."
        case .copy:
            return "These options can be used to import the database from other device."
        case .write:
            return "After successfullly imported, if the file is valid then it will write all Health data to HealthKit"
        case .share:
            return "This used to export the locally stored database with other device"
        case .clearAll:
            return "This option will clear all the files and folder in local and kill the app"
        }
    }
    
    func rows() -> [Row] {
        switch self {
        case .readStore:
            return [.range, .readStoreAction]
        case .copy:
            return [.copyFromClipbord, .copyFromShare]
        case .write:
            return [.write]
        case .share:
            return [.copyToClipbord, .share]
        case .clearAll:
            return [.clearAll]
            
        }
    }
    
    
}

let shareRangeSegueIdentifier = "ShareToRangeSegue"
class ShareViewController: UIViewController, DateRangeViewControllerDelegate {
   

    @IBOutlet weak var tableView: UITableView!
    
    private let sections:[Section] = [.readStore,
                                      .share,
                                      .copy,
                                      .write,
                                      .clearAll]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Share"
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
        let url = URL(string: "youtube://")
        print("Can openURL \(UIApplication.shared.canOpenURL(url!))")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is DateRangeViewController {
            if let dateRangeVC: DateRangeViewController = segue.destination as? DateRangeViewController {
                dateRangeVC.dateRange = dateRange
                weak var weakSelf = self
                dateRangeVC.dateRangeDelegate =  weakSelf
            }
        }
    }
    
    //MARK: DateRangeViewController Delegate
    func didChangeRange(newDateRange: DateRange) {
        dateRange = newDateRange
        tableView.reloadData()
    }
    
}

extension ShareViewController: UITableViewDelegate,UITableViewDataSource {
    //MARK: TableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        var row = sections[indexPath.section].rows()[indexPath.row]
        
        cell.textLabel?.text = row.title()
        
        switch row {
        case .range:
            cell = UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: nil)
            cell.textLabel?.text = row.title()
            cell.detailTextLabel?.text = dateRange.displayText()
            cell.detailTextLabel?.numberOfLines = 0
            cell.accessoryType = .disclosureIndicator
        default:
            cell.textLabel?.textColor = cell.textLabel?.tintColor
           row = .readStoreAction
        }
        
        
        
        return cell
    }
    
    //MARK: TableViewDelegate
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].headerTitle()
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footerTitle()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = sections[indexPath.section].rows()[indexPath.row]
        
        switch row {
        case .range:
            dateRangeSelected()
        case .readStoreAction:
            readAndStoreSelected()
        case .copyFromClipbord:
            importFromClipboardSelected()
        case .copyFromShare:
            importFromSharedExtensionSelected()
        case .write:
            writeDateToHealthKitSelected()
        case .copyToClipbord:
            copyToClipboardSelected()
        case .share:
            shareSelected()
        case .clearAll:
            clearAllSelected()
        }
        
    }
}

extension ShareViewController {

    //Selections
    
    func dateRangeSelected(){
        self.performSegue(withIdentifier: shareRangeSegueIdentifier, sender: self)
    }
    
    func shareWithDropboxSelected(){
        
        UIApplication.shared.open(URL(string: "dropbox://")!, options: [:]) { (opened) in
            print("\(opened)")
        }
    }
    
    func readAndStoreSelected(){
        
        startActivitiyIndicator(message: "Copying from Health....")
        OperationQueue.main.addOperation {
            //Your
            let folderPath = FileUtitlity.getDocumentryLocalDataFilePath()
            let folderURL = URL(fileURLWithPath: folderPath)
            do{
                if(FileManager.default.fileExists(atPath: folderURL.path)){
                    try FileManager.default.removeItem(at: folderURL)
//                    HSPersistentStore.reinitializeLocalPersistentStore()
                }
            }catch let error {
                print("Error while removing the SQliteFile \(error)")
                self.stopAcitivityIndicator()
            }
            
            HealthKtiManager.shared.fetchAllHealthData{ (completed, hksamples, error) in
                OperationQueue.main.addOperation {
                    if let samples = hksamples {
//                        HSPersistentStore.localPersistent.saveHKSamples(samples)
                        let saved = NSKeyedArchiver.archiveRootObject(samples, toFile: FileUtitlity.getDocumentryLocalDataFilePath())
                        if saved {
                            print("Data written to local")
                        }
                    }
                    self.stopAcitivityIndicator()
                    if error != nil {
                        UIAlertController.showSimpleAlert("Error!", message: error?.localizedDescription, viewController: self)
                    }else{
                        UIAlertController.showSimpleAlert("Info!", message: "All Healthkit data copied to app database. Now ready to share", viewController: self)
                    }
                }
            }
        }
    }
    
    func importFromClipboardSelected(){
        
        var copied  = false
        startActivitiyIndicator(message: "Copying from Clipboard in progress....")
        OperationQueue.main.addOperation {
            
            if UIPasteboard.general.contains(pasteboardTypes: [jpgFilePasteBoardString]) {
                
                let fileData = UIPasteboard.general.value(forPasteboardType: jpgFilePasteBoardString)
                
                if let imgFileData:Data = fileData as? Data {
                    
                    let pasteImageURLPath = FileUtitlity.getDocumentryUnknownDataFilePath()
                    
                    if( FileManager.default.fileExists(atPath: pasteImageURLPath)){
                        do {
                            try FileManager.default.removeItem(atPath: pasteImageURLPath)
                        } catch let error {
                            print("Error while removing the file \(error)")
                        }
                    }
                    do {
                        
                        try imgFileData.write(to: URL.init(fileURLWithPath: pasteImageURLPath) )
//                        try SSZipArchive.unzipFile(atPath: pasteSqliteURLPath, toDestination: FileUtitlity.getDocumentsDirectory(), overwrite: true, password: zipPassword)
//                        try FileManager.default.removeItem(atPath: pasteSqliteURLPath)
                        copied = true
                    } catch let error{
                        print("Error while writing the data \(error)")
                        UIAlertController.showSimpleAlert("Error", message: "Error while writing the data \(error)", viewController: self)
                    }
                    
                }
            }
            
            if !copied {
                UIAlertController.showSimpleAlert("Zip file error", message: "Clipboard data is not a zip file", viewController: self)
            }else{
//                HSPersistentStore.reinitializeUnknownPersistentStore()
                UIAlertController.showSimpleAlert("Success!", message: "Successfully copied from clipboard", viewController: self)
            }
            self.stopAcitivityIndicator()
        }
        
    }
    
    func importFromSharedExtensionSelected(){
        startActivitiyIndicator(message: "Copying from shared space....")
        OperationQueue.main.addOperation {
            let unknownImagePath = FileUtitlity.getGroupShareUnknownDataFilePath()
            let localDocuImageFile = FileUtitlity.getDocumentryLocalDataFilePath()
//            let documentDirectoryDatabasePath = FileUtitlity.getDocumentsDirectoryDatabse()
            do{
                if( FileManager.default.fileExists(atPath: unknownImagePath )){
                    if( FileManager.default.fileExists(atPath: localDocuImageFile)){
                        
                        try FileManager.default.removeItem(atPath: localDocuImageFile)
                        
                    }
                    try FileManager.default.copyItem(atPath: unknownImagePath, toPath: localDocuImageFile)
                    
                }else{
                    UIAlertController.showSimpleAlert("Error!", message: "No data available in shared location", viewController: self)
                }
            }catch let error {
                UIAlertController.showSimpleAlert("Error!", message: "Error while copying from share extension: \(error)", viewController: self)
            }
            self.stopAcitivityIndicator()
        }
    }
    
    func writeDateToHealthKitSelected(){
        
        if( FileManager.default.fileExists(atPath: FileUtitlity.getDocumentryUnknownDataFilePath())){
            self.startActivitiyIndicator(message: "Writing data to Health.....")
            OperationQueue.main.addOperation {
                let unarchivedObjects = NSKeyedUnarchiver.unarchiveObject(withFile: FileUtitlity.getDocumentryUnknownDataFilePath())
                guard let decodedSamples =  unarchivedObjects as? [HKSample] else{
                    print("Samples are invalid")
                    self.stopAcitivityIndicator()
                    return
                }
                HealthKtiManager.shared.writeToHealthKit(hkSamples: decodedSamples, completion: { (completed, errors) in
                    do{
                        if errors.count == 0 {
                            try FileManager.default.removeItem(atPath: FileUtitlity.getDocumentryUnknownDataFilePath())
//                            HSPersistentStore.reinitializeUnknownPersistentStore()
                            UIAlertController.showSimpleAlert("Success!", message: "All data from local written to AHK and local get cleared", viewController: self)
                        }else{
                            UIAlertController.showSimpleAlert("Error!", message: "Error while writing the data to AHK: \(errors)", viewController: self)
                        }
                    }catch let error {
                        UIAlertController.showSimpleAlert("Error!", message: "Error while removing the zip file: \(error)", viewController: self)
                    }
                    self.stopAcitivityIndicator()
                })
            }
        }else{
            UIAlertController.showSimpleAlert("Error!", message: "No new database available", viewController: self)
        }
    }
    
    func copyToClipboardSelected(){
        //Your
        let folderPath = FileUtitlity.getDocumentryLocalDataFilePath()
        let folderURL = URL(fileURLWithPath: folderPath)
        
        if(FileManager.default.fileExists(atPath: folderURL.path)){
//            do{
            
                UIPasteboard.general.setValue(folderPath, forPasteboardType: jpgFilePasteBoardString)
                UIAlertController.showSimpleAlert("Copied!", message: "local database file copied to clipboard", viewController: self)
//            }catch let error {
//                print("error while loading the zip file \(error)")
//            }
//
        }else{
            UIAlertController.showSimpleAlert("No database", message: "You can generate the database by clicking \"Copy all HealthKit data to local\" ", viewController: self)
        }
        
    }
    
    func shareSelected(){
        //Your
        let folderPath = FileUtitlity.getDocumentryLocalDataFilePath()
        let folderURL = URL(fileURLWithPath: folderPath)
        
        if(FileManager.default.fileExists(atPath: folderURL.path)){
//            do{
//                let zipFilePath = FileUtitlity.getDocumentryZipFilePath()
//                if(FileManager.default.fileExists(atPath: zipFilePath)){
//                    try FileManager.default.removeItem(at: URL.init(fileURLWithPath: zipFilePath))
//                }
//                SSZipArchive.createZipFile(atPath: zipFilePath, withContentsOfDirectory: folderPath, keepParentDirectory: true)
                
                let activityVC = UIActivityViewController(activityItems: [URL.init(fileURLWithPath: folderPath)], applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
//            }catch let error {
//                print("error while loading the zip file \(error)")
//            }
            
        }else{
            UIAlertController.showSimpleAlert("No database", message: "You can generate the database by clicking \"Copy all HealthKit data to local\" ", viewController: self)
        }
        
    }
    
    func clearAllSelected(){
        self.startActivitiyIndicator(message: "Writing data to Health.....")
        OperationQueue.main.addOperation {
            do{
                let supportDatabase = FileUtitlity.getDocumentryLocalDataFilePath()
                let documentDirectoryBase = FileUtitlity.getDocumentryUnknownDataFilePath()
                let unknownZipPath = FileUtitlity.getDocumentryLocalDataFilePath()
//                let directoryContents = try FileManager.default.contentsOfDirectory(atPath: documentDirectoryBase)
                let paths = [supportDatabase,documentDirectoryBase,unknownZipPath]
//                paths.append(contentsOf: directoryContents)
                for path in paths {
                    if FileManager.default.fileExists(atPath: path){
                        try FileManager.default.removeItem(at: URL(fileURLWithPath: path))
                    }
                }
                UIAlertController.showSimpleAlert("Success!", message: "All local database files are cleared", viewController: self)
                exit(0)
            }catch let error {
                UIAlertController.showSimpleAlert("Error!", message: "Error while clearing local data: \(error)", viewController: self)
            }
            self.stopAcitivityIndicator()
        }
    }
    
}
