//
//  ShareViewController.swift
//  shareExtension
//
//  Created by Tamilarasu on 23/01/18.
//  Copyright © 2018 Tamilarasu Ponnusamy. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let content = extensionContext!.inputItems[0] as! NSExtensionItem
        let contentType = "public.image"
        var isValidContext = false
        for attachment in content.attachments as! [NSItemProvider] {
            if attachment.hasItemConformingToTypeIdentifier(contentType) {
                isValidContext = true;
                attachment.loadDataRepresentation(forTypeIdentifier: contentType, completionHandler: { (data, error) in
                    if error == nil {
                        
                    } else {
                        
                        let alert = UIAlertController(title: "Error", message: "Error loading file", preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "Error", style: .cancel) { _ in
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
        
        if !isValidContext {
            let alert = UIAlertController(title: "Error", message: "Not valid file format", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Dismiss", style: .cancel) { _ in
                self.cancel()
                self.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        let content = extensionContext!.inputItems[0] as! NSExtensionItem
        let contentType = "public.data"
        let contentTypeURL = "public.url"
        
        var isWriteData = false
        for attachment in content.attachments as! [NSItemProvider] {
            if (attachment.hasItemConformingToTypeIdentifier(contentType) || attachment.hasItemConformingToTypeIdentifier(contentTypeURL)) {
                isWriteData = true
                attachment.loadDataRepresentation(forTypeIdentifier: contentType, completionHandler: { (data, error) in
                    if error == nil {
                        var copied  = false
                        let pasteSqliteURLPath = FileUtitlity.getGroupShareUnknownDataFilePath()
                        //                let pasteSqliteURL = URL(fileURLWithPath: pasteSqliteURLPath)
                        if( FileManager.default.fileExists(atPath: pasteSqliteURLPath)){
                            do {
                                try FileManager.default.removeItem(atPath: pasteSqliteURLPath)
                            } catch let error {
                                print("Error while removing the file \(error)")
                            }
                        }
                        if let zipData = data {
                            do {
                                try zipData.write(to: URL.init(fileURLWithPath: pasteSqliteURLPath))
                                copied = true
                            } catch let error{
                                print("Error while writing the data \(error)")
                                UIAlertController.showSimpleAlert("Error", message: "Error while writing the data \(error)", viewController: self)
                            }
                        }
                        if !copied {
                            UIAlertController.showSimpleAlert("Error", message: "Its not an string", viewController: self)
                        }else{
//                            exit(0)
                        }
                    } else {
                        
                        let alert = UIAlertController(title: "Error", message: "Error loading file", preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "Error", style: .cancel) { _ in
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
                attachment.loadFileRepresentation(forTypeIdentifier: contentTypeURL, completionHandler: { (contentURL, error) in
                    if error == nil {
                        var copied  = false
                        let pasteSqliteURLPath = FileUtitlity.getGroupShareUnknownDataFilePath()
                        //                let pasteSqliteURL = URL(fileURLWithPath: pasteSqliteURLPath)
                        if( FileManager.default.fileExists(atPath: pasteSqliteURLPath)){
                            do {
                                try FileManager.default.removeItem(atPath: pasteSqliteURLPath)
                            } catch let error {
                                print("Error while removing the file \(error)")
                            }
                        }
                        var data:Data?
                        if contentURL != nil {
                            if( FileManager.default.fileExists(atPath: (contentURL?.path)!)){
                                do {
                                    data = try Data.init(contentsOf: contentURL!)
                                } catch let error {
                                    print("Error while removing the file \(error)")
                                }
                            }
                        }
                        if let zipData = data {
                            do {
                                try zipData.write(to: URL.init(fileURLWithPath: pasteSqliteURLPath))
                                copied = true
                            } catch let error{
                                print("Error while writing the data \(error)")
                                UIAlertController.showSimpleAlert("Error", message: "Error while writing the data \(error)", viewController: self)
                            }
                        }
                        if !copied {
                            UIAlertController.showSimpleAlert("Error", message: "Its not an string", viewController: self)
                        }else{
                            //                            exit(0)
                        }
                    } else {
                        
                        let alert = UIAlertController(title: "Error", message: "Error loading file", preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "Error", style: .cancel) { _ in
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
//                attachment.loadItem(forTypeIdentifier: contentType, options: nil, completionHandler: { (data, error) in
//                    if error == nil {
//                        let sqliteURL = URL(fileURLWithPath: ShareViewController.getDocumentsDirectory()).appendingPathComponent("HealthSource.sqlite")
//                        if data is Data {
//                        do {
//                            let sqliteData: Data = data as! Data
//                            try sqliteData.write(to: sqliteURL)
//                        } catch let error{
//                            print("Error while writing the data \(error)")
//                        }
//                        }
//                    } else {
//                        
//                        let alert = UIAlertController(title: "Error", message: "Error loading file", preferredStyle: .alert)
//                        
//                        let action = UIAlertAction(title: "Error", style: .cancel) { _ in
//                            self.dismiss(animated: true, completion: nil)
//                        }
//                        
//                        alert.addAction(action)
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                })
            }
        }
        if isWriteData {
            let alert = UIAlertController(title: "Error", message: "Error loading file", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Error", style: .cancel) { _ in
                self.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
        print("Nothing happens \(content)")
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        let item1 =  SLComposeSheetConfigurationItem()
        item1?.title = "Nothing"
        return [item1 as Any]
    }

    
    public static func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    public static func getApplicationSupportDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let path = paths[0]
        return path
    }
    
//    public static func getDocumentsDirectorySqlitePath() -> String {
//        
//        return ShareViewController.getDocumentsDirectory() + "/HealthSource.sqlite"
//    }
//    
//    public static func getApplicationSupportDirectoryUnknowSqlitePath() -> String {
//        
//        return ShareViewController.getDocumentsDirectory() + "/UnknownHealthSource.sqlite"
//    }
//    
//    public static func getApplicationSupportDirectorySqlitePath() -> String {
//        return ShareViewController.getApplicationSupportDirectory() + "/HealthSource.sqlite"
//    }
}
