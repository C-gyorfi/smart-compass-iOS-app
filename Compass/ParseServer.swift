//
//  ParseServer.swift
//  Compass
//
//  Created by Csabi on 12/09/2018.
//  Copyright © 2018 Csabi. All rights reserved.
//

import Foundation
import Parse

class PServer {
    
    func initParse(appID: String, clKey: String, serverAddress: String) {

        Parse.enableLocalDatastore()
        //find parse
        let parseConfig = ParseClientConfiguration(block:  {(ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = appID
            ParseMutableClientConfiguration.clientKey = clKey
            ParseMutableClientConfiguration.server = serverAddress
        })
        
        Parse.initialize(with: parseConfig)
        PFUser.enableAutomaticUser()
        let defaultACL = PFACL()
        defaultACL.hasPublicReadAccess = true
        
        PFACL.setDefault(defaultACL, withAccessForCurrentUser: true)
        
    }
    
    func saveUserLocation(classN: String, uData: UserData) {
        let saveObject = PFObject(className: classN)
        saveObject["UserName"] = uData.name
        saveObject["Location"] = PFGeoPoint(location: uData.location)
        saveObject.saveInBackground { (success, error) -> Void in
            if error != nil { print(error ?? "Something went wrong...")
            }
            else {
                UserDefaults.standard.set(saveObject.objectId, forKey: "objectID")
                print("Location saved to server") }
        }
    }
    
    func fetchUserData(classN: String, uData: UserData) {
        let quiery = PFQuery(className: classN)
        quiery.getObjectInBackground(withId: uData.name, block: { (object, error) in
            if error != nil {
                print(error ?? "Failed to fetch data")
            } else {
                if let newUserData = object {
                print(newUserData)}
            }
        })
    }
}

class UserData {
    //best practice to use get/set?
    var name = String()
    
    var location = CLLocation()
}
