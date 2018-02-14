//
//  FileUtitlity.swift
//  HealthSource
//
//  Created by Tamilarasu on 24/01/18.
//  Copyright © 2018 Tamilarasu. All rights reserved.
//

import UIKit

class FileUtitlity: NSObject {
    
    //MARK: - Paths
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
    //MARK: -Database Folder
    public static func getDocumentsDirectoryDatabse() -> String {
        return  FileUtitlity.getDocumentsDirectory()+"/Database"
    }
    
    public static func getDocumentsDirectoryDropboxUpload() -> String {
        return  FileUtitlity.getDocumentsDirectory()+"/DropboxUpload"
    }
    
    public static func getDocumentsDirectoryDropboxPendingUpload() -> String {
        return  FileUtitlity.getDocumentsDirectoryDropboxUpload()+"/Pending"
    }
    
    public static func getApplicationSupportDirectoryDatabase() -> String {
        return  FileUtitlity.getApplicationSupportDirectory()+"/Database"
    }
    
    //MARK: -Database Sqlite
    public static func getDocumentsDirectorySqlitePath() -> String {
        return FileUtitlity.getDocumentsDirectoryDatabse() + "/HealthSource.sqlite"
    }
    
    public static func getApplicationSupportDirectorySqlitePath() -> String {
        return FileUtitlity.getApplicationSupportDirectoryDatabase() + "/HealthSource.sqlite"
    }
    
    //MARK: -Database Unknown Sqlite
    
    public static func getApplicationSupportDirectoryUnknowSqlitePath() -> String {
        
        return FileUtitlity.getApplicationSupportDirectory() + "/UnknownHealthSource.sqlite"
    }
    
    public static func getDocumentDirectoryUnknowSqlitePath() -> String {
        
        return FileUtitlity.getDocumentsDirectory() + "/UnknownHealthSource.sqlite"
    }
    
    //MARK: -Zip
    
    public static func getApplicationSupportDirectoryUnknowZipPath() -> String {
        
        return FileUtitlity.getApplicationSupportDirectoryDatabase() + "/healthData.zip"
    }
    
    public static func getDocumentryZipFilePath() ->String {
        return FileUtitlity.getDocumentsDirectory() + "/healthData.zip"
    }
    
    public static func getDocumentryNewZipFilePath() ->String {
        return FileUtitlity.getDocumentsDirectory() + "/newhealthData.zip"
    }
    
    public static func getDocumentryLocalDataFilePath() ->String {
        return FileUtitlity.getDocumentsDirectory() + "/localHealthData.jpg"
    }
    
    
    public static func getDocumentryTempFilePath() ->String {
        return FileUtitlity.getDocumentsDirectory() + "/Temp/localHealthData.jpg"
    }
    
    public static func getDocumenDirectoryUnknownDataFilePath() ->String {
        return FileUtitlity.getDocumentsDirectoryDatabse() + "/localHealthData.jpg"
    }
    //MARK:-Group Container
    
    public static func getGroupSharedContainerPath() -> String? {
        
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.rdalabs.HealthSource")?.path
    }
    
    public static func getGroupShareUnknowSqlitePath() -> String {
        
        return (FileUtitlity.getGroupSharedContainerPath() ?? "") + "/UnknownHealthSource.sqlite"
    }
    
    public static func getGroupShareUnknowZipPath() -> String {
        
        return (FileUtitlity.getGroupSharedContainerPath() ?? "") + "/healthData.zip"
    }

    public static func getGroupShareUnknownDataFilePath() ->String {
        return (FileUtitlity.getGroupSharedContainerPath() ?? "") + "/unknownHealthData.jpg"
    }
}
