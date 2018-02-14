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
    case followLink
    case downloadWrite
    case autoDownload
    case autoDownloadOverWifiOnly
    case unfollowLink
    
    func title() -> String {
        switch self {
        case .followLink:
            return "Paste Link"
        case .downloadWrite:
            return "Download & Write"
        case .autoDownload:
            return "Auto Download"
        case .autoDownloadOverWifiOnly:
            return "Auto Download over WiFi only"
        case .unfollowLink:
            return "Unfollow Link"
        }
    }
}

fileprivate enum Section {

    case follow
    case downloadWrite
    case unfollow
    func headerTitle() -> String {
        switch self {
        case .follow:
            return "Download"
        case .downloadWrite:
            return "Download & Add to HealthKitData"
        case .unfollow:
            return ""
        }
    }
    
    func footerTitle() -> String {
        switch self {
        case .follow:
            return "Paste the dropbox link which shared from another device."
        case .downloadWrite:
            return "If the link is valid then it will keep on downloading the data from dropbox and it will write to HealthKit."
        case .unfollow:
            return "By clicking this will stop downloading the data from above link."
        }
    }
    
    func rows() -> [Row] {
        switch self {
        case .follow:
            return [.followLink]
        case .downloadWrite:
            return [.downloadWrite, .autoDownload, .autoDownloadOverWifiOnly]
        case .unfollow:
            return [.unfollowLink]
            
        }
    }
    
    
}

//let homeRangeSegueIdentifier = "HomeToRangeSegue"
//let zipFilePasteBoardString = "public.zip-archive"
//let jpgFilePasteBoardString = "public.image"
class DropboxDownloadVIewController: UIViewController, DateRangeViewControllerDelegate {
   

    @IBOutlet weak var tableView: UITableView!
    
    private let sections:[Section] = [.follow,
                                      .downloadWrite,
                                      .unfollow]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Download"
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
       
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

extension DropboxDownloadVIewController: UITableViewDelegate,UITableViewDataSource {
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
        case .followLink:
            followLink()
        case .autoDownload:
            autoDownload()
        case .autoDownloadOverWifiOnly:
            autoDownloadOverWiFiOnly()
        case .unfollowLink:
            unFollowLink()
        case .downloadWrite:
            downloadAndWrite()
        }
        
    }
}

extension DropboxDownloadVIewController {

    //Selections
    
    func followLink() {
        
    }
    
    func downloadAndWrite(){
        
    }
    
    func autoDownload() {
        
    }
    
    func autoDownloadOverWiFiOnly() {
        
    }
    
    func unFollowLink() {
        
    }
    
}

