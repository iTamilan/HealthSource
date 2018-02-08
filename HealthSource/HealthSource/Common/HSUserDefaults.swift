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
