//
//  DropboxHandler.swift
//  HealthSource
//
//  Created by Tamilarasu on 08/02/18.
//  Copyright © 2018 Tamilarasu. All rights reserved.
//

import Foundation
import SwiftyDropbox

public class DropBoxManager {
    public static let shared = DropBoxManager(with: dropboxAppKey)
    
    let appKey:String
    
    //MARK: Init
    
    public init(with appKey:String){
        self.appKey = appKey
        DropboxClientsManager.setupWithAppKey(appKey)
    }
    
    //MARK: Authendications
    public func userAuthendicated() -> Bool {
            return DropboxClientsManager.authorizedClient != nil
    }
    
    public static func authorizeFromController(controller: UIViewController?, completion: @escaping ((Bool) -> Void)){
        
        DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: controller, openURL: {(url: URL) -> Void in
                completion(DropBoxManager.shared.handleRedirectURL(url))
        })
    }
    
    public func reauthorizeClient(_ tokenUid: String) {
       DropboxClientsManager.reauthorizeClient(tokenUid)
    }
    
    public func logoutDropbox(){
        DropboxClientsManager.unlinkClients()
    }
    //MARK: Handle Redirect URL
    public func handleRedirectURL(_ url: URL) -> Bool{
        
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                print("Success! User is logged into DropboxClientsManager.")
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                print("Error: \(description)")
            }
            return true
        }
        return false
    }
}
