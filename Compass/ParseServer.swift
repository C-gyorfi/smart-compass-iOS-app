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
       // PFUser.enableAutomaticUser()
        let defaultACL = PFACL()
        defaultACL.hasPublicReadAccess = true
        
        PFACL.setDefault(defaultACL, withAccessForCurrentUser: true)
        
    }
    
    func saveUserLocation(classN: String, uData: UserData) {
        let saveObject = PFObject(className: classN)
        saveObject["UserName"] = uData.name
        saveObject["Location"] = PFGeoPoint(location: uData.location)
        //object ID is being returned before updated because its saving in BG
        saveObject.saveInBackground { (success, error) -> Void in
            if error != nil { print(error ?? "Something went wrong...")
            }
            else {
                UserDefaults.standard.set(saveObject.objectId, forKey: uData.name)
                UserDefaults.standard.set(uData.name, forKey: "userName")
                print("Location saved to server")
            }
        }
    }
    
    func updateUserLocation(classN: String, uData: UserData) -> Bool {
        var isUpdated = false
        let quiery = PFQuery(className: classN)
        quiery.getObjectInBackground(withId: uData.objectID, block: { (object, error) in
            if error != nil {
                print(error ?? "Failed to fetch data")
            } else {
                if let newUserData = object {
                    newUserData["Location"] = PFGeoPoint(location: uData.location)
                    newUserData.saveInBackground(block: { (sucess, error) in
                        if error != nil {
                            print(error ?? "Failed to update data")
                        }
                        else {
                            isUpdated = true
                            print("Location updated for user: \(uData.name)")
                        }
                    })
                }
            }
        })
      return isUpdated
    }
}

class UserData {
    //best practice to use get/set?
    var name = String()
    var password = String()
    var location = CLLocation()
    var objectID = String()
}
