//
//  DropboxHandler.swift
//  HealthSource
//
//  Created by Tamilarasu on 08/02/18.
//  Copyright © 2018 Tamilarasu. All rights reserved.
//

import Foundation
import SwiftyDropbox

typealias CompletionHandler = (Bool) -> Void
public class DropBoxManager {
    public static let shared = DropBoxManager(with: dropboxAppKey)
    
    let appKey:String
    
    private var completionHandler : CompletionHandler?
    //MARK: Init
    
    public init(with appKey:String){
        self.appKey = appKey
        DropboxClientsManager.setupWithAppKey(appKey)
    }
    
    //MARK: Authendications
    public func userAuthendicated() -> Bool {
            return DropboxClientsManager.authorizedClient != nil
    }
    
    public func authorizeFromController(controller: UIViewController?, completion: @escaping ((Bool) -> Void)){
        self.completionHandler = completion
        DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: controller, openURL: {(url: URL) -> Void in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
            if let completionHandlerAvailable = completionHandler {
                completionHandlerAvailable(true)
                completionHandler = nil
            }
            return true
        }
        if let completionHandlerAvailable = completionHandler {
            completionHandlerAvailable(false)
            completionHandler = nil
        }
        return false
    }
}
