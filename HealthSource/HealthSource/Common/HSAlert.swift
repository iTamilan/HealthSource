//
//  HSAlert.swift
//  HealthSource
//
//  Created by Tamilarasu on 12/02/18.
//  Copyright © 2018 Tamilarasu. All rights reserved.
//

import Foundation
import UIKit
//MARK: - Alert
extension UIAlertController{
    public static func showSimpleAlert(_ title:String?, message: String?, viewController:UIViewController?){
        alert(title, message: message, cancelButtonTitle: "Dismiss", otherButtonTitles: nil, distructiveButtonIndex: nil, viewController: viewController)
    }
    
    public static func alert(_ title:String?, message: String?, cancelButtonTitle:String?,otherButtonTitles:[String]?,distructiveButtonIndex:[Int]?,viewController:UIViewController?, handler: ((Int,UIAlertAction) -> Swift.Void)? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var count = 0
        if let cancel = cancelButtonTitle {
            let currentCount = count
            let action = UIAlertAction(title: cancel, style: .cancel, handler: { (action) in
                if let completionHandler = handler {
                    completionHandler(currentCount,action)
                }
            })
            alert.addAction(action)
            count = count+1
        }
        if let buttonTitles = otherButtonTitles {
            
            for buttonTitle in buttonTitles {
                let currentCount = count
                var style = UIAlertActionStyle.default
                if let distructiveIndexs = distructiveButtonIndex {
                    if distructiveIndexs.contains(currentCount) {
                        style = .destructive
                    }
                }
                let action = UIAlertAction(title: buttonTitle, style: style, handler: { (action) in
                    if let completionHandler = handler {
                        completionHandler(currentCount,action)
                    }
                })
                alert.addAction(action)
                count = count+1
            }
        }
        
        viewController?.present(alert, animated: true, completion: nil)
    }
    
}
