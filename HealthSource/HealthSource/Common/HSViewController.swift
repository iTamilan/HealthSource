//
//  HSViewController.swift
//  HealthSource
//
//  Created by Tamilarasu on 10/02/18.
//  Copyright © 2018 Tamilarasu. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

extension UIViewController:NVActivityIndicatorViewable {
    //MARK: Activity indicatore views
    func startActivitiyIndicator(message:String) {
        
        startAnimating(CGSize(width:self.view.bounds.size.width,height:50),
                       message:message)
    }
    
    func stopAcitivityIndicator() {
        stopAnimating()
    }
}
