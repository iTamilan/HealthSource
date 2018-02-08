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
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let action = UIAlertAction(title: "Dismiss", style: .cancel) { _ in
    }
    alert.addAction(action)
    viewController?.present(alert, animated: true, completion: nil)
    }
}
