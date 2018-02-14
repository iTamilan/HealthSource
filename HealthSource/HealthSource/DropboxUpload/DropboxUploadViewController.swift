//
//  HomeViewController.swift
//  HealthSource
//
//  Created by Tamilarasu on 10/02/18.
//  Copyright © 2018 Tamilarasu. All rights reserved.
//

import UIKit
import HealthKit

fileprivate enum Row{
    case link
    case unlink
    case readUpload
    case autoUpload
    case autoUploadOverWifiOnly
    case createSharedLink
    case copyToClipboard
    case shareExtension
    
    func title() -> String {
        switch self {
        case .link:
            return "Link your Dropbox"
        case .unlink:
            return "Logout dropbox"
        case .readUpload:
            return "Read & upload"
        case .autoUpload:
            return "Auto upload"
        case .autoUploadOverWifiOnly:
            return "Auto upload over WiFi only"
        case .createSharedLink:
            return "Create Shared Link"
        case .copyToClipboard:
            return "Copy To Clipboard"
        case .shareExtension:
            return "Share Link"
        }
    }
}

fileprivate enum Section {
    case login
    case logout
    case readUpload
    case share
    func headerTitle() -> String {
        switch self {
        case .login:
            return "Link Dropbox"
        case .logout:
            return ""
        case .readUpload:
            return "Read & upload HealthKitData"
        case .share:
            return "Share"
        }
    }
    
    func footerTitle() -> String {
        switch self {
        case .login:
            return "Link your \"DROPBOX\" to share your Health Data through dropbox."
        case .logout:
            return "This will stop uploading your HealthData to Dropbox"
        case .readUpload:
            return "It will read the HealthKit data periodically and start uploading data to your dropbox account. By enabling the \"AutoUpload\" will read and upload the HealthData for every 15 min interval. By enabling the \"Auto Upload over WiFi onnly\" will enable the automated upload only over WiFi but read and store locally will happen."
        case .share:
            return "By clicking this will generate a sharable link. This link will be used in Follow link sections on another device."
        }
    }
    
    func rows() -> [Row] {
        switch self {
        case .login:
            return [.link]
        case .logout:
            return [.unlink]
        case .readUpload:
            return [.readUpload,.autoUpload,.autoUploadOverWifiOnly]
        case .share:
            return [.createSharedLink, .copyToClipboard, .shareExtension]
            
        }
    }
    
    
}

//let homeRangeSegueIdentifier = "HomeToRangeSegue"
//let zipFilePasteBoardString = "public.zip-archive"
let jpgFilePasteBoardString = "public.image"
class DropboxUploadViewController: UIViewController, DateRangeViewControllerDelegate {
   

    @IBOutlet weak var tableView: UITableView!
    
    private let sections:[Section] = [.login,
                                      .readUpload,
                                      .share,
                                      .logout,
                                      ]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Upload"
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

extension DropboxUploadViewController: UITableViewDelegate,UITableViewDataSource {
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
        
//        switch row {
//        case .range:
//            cell = UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: nil)
//            cell.textLabel?.text = row.title()
//            cell.detailTextLabel?.text = dateRange.displayText()
//            cell.detailTextLabel?.numberOfLines = 0
//            cell.accessoryType = .disclosureIndicator
//        case .shareWithDropbox:
//            cell.accessoryType = .disclosureIndicator
//        default:
////            cell.textLabel?.textColor = cell.textLabel?.tintColor
//        }
        
        
        
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
        case .link:
            linkDropBox()
        case .unlink:
            logoutDropBox()
        case .readUpload:
            readUplaodData()
        case .autoUpload:
            auotUpload()
        case .autoUploadOverWifiOnly:
            autoUploadOverWiFiOnly()
        case .createSharedLink:
            createShareLink()
        case .copyToClipboard:
            copyToClipboard()
        case .shareExtension:
            shareExtension()
        }
        
    }
}

extension DropboxUploadViewController {

    //Selections
    
    func linkDropBox(){
        
    }
    
    func logoutDropBox(){
        
    }
    
    func readUplaodData(){
        
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
    
    func auotUpload(){
        
    }
    
    func autoUploadOverWiFiOnly() {
        
    }
    
    func createShareLink() {
        
    }
    
    func copyToClipboard(){
        
    }
    
    func shareExtension(){
        
    }
    
}
