//
//  UserDefaults.swift
//  HealthSource
//
//  Created by Tamilarasu on 11/02/18.
//  Copyright © 2018 Tamilarasu. All rights reserved.
//

import Foundation
import HealthKit
private let hkQueryAnchrodUDKey = "HKQueryAnchrodUDKey"
typealias HSQueryAnchorDictionay = [String:HKQueryAnchor]

class HSUserDefaults {
    static let shared = HSUserDefaults()
    
    func getHKAnchorQueryDictionary() -> HSQueryAnchorDictionay {
        
        if let dictinory = UserDefaults.standard.object(forKey: hkQueryAnchrodUDKey) {
            return dictinory as! HSQueryAnchorDictionay
        }
        return [:]
        
    }
    
    func setHKQueryAnchoreDicionary(dictionory:HSQueryAnchorDictionay){
        UserDefaults.standard.set(dictionory, forKey: hkQueryAnchrodUDKey)
        UserDefaults.standard.synchronize()
    }
}

private let autoUploadUDKey = "AutoUploadUDKey"
private let autoUploadWiFiUDKey = "AutoUploadWiFiUDKey"
private let autoUploadSharedUDKey = "AutoUploadSharedLinkUDKey"

extension HSUserDefaults {
    
    static func autoUpload() -> Bool {
        return UserDefaults.standard.bool(forKey: autoUploadUDKey)
    }
    
    static func setAutoUpload(_ auto: Bool){
        UserDefaults.standard.set(auto, forKey: autoUploadUDKey)
        UserDefaults.standard.synchronize()
    }
    
    static func setAutoUploadOverWifi(_ auto: Bool){
        UserDefaults.standard.set(auto, forKey: autoUploadWiFiUDKey)
        UserDefaults.standard.synchronize()
    }
    
    static func autoUploadOverWiFi() -> Bool {
        return UserDefaults.standard.bool(forKey: autoUploadWiFiUDKey)
    }
    
    static func setAutoUploadSharedLink(_ urlPath: String){
        UserDefaults.standard.set(urlPath, forKey: autoUploadSharedUDKey)
        UserDefaults.standard.synchronize()
    }
    
    static func autoUploadSharedLink() -> String? {
        return UserDefaults.standard.value(forKey: autoUploadSharedUDKey) as? String
    }
}

