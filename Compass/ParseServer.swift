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
        saveObject["UserName"] = PFUser.current()?.username
        saveObject["Location"] = PFGeoPoint(location: uData.location)
        //object ID is being returned before updated because its saving in BG
        saveObject.saveInBackground { (success, error) -> Void in
            if error != nil { print(error ?? "Something went wrong...")
            }
            else {
                UserDefaults.standard.set(saveObject.objectId, forKey: "locationObjectId")
                print("New location object saved to server")
            }
        }
    }
    
    //this is could be more "reusable" possibly with key/equalto attributes, but for now I can get the object id for username
    //It will return a Nil
    func getObjectId(classN: String, uData: UserData) {
        let quiery = PFQuery(className: classN)
        quiery.whereKey("UserName", equalTo: PFUser.current()?.username)
        
        quiery.findObjectsInBackground { (objects, error) in
            guard error == nil else {
                print(error)
                return
            }
            guard let objects = objects else {
                print("objects not found")
                return
            }
                if let objectID = objects.first?.objectId {
                    print("fetched location id for curr user, id: \(objectID)")
                    UserDefaults.standard.set(objectID, forKey: "locationObjectId")
                } else {
                    self.saveUserLocation(classN: classN, uData: uData)
            }
        }
    }
    
    func deleteObjects(classN: String, uData: UserData) {
        let query = PFQuery(className: classN)
        query.whereKey("UserName", equalTo: PFUser.current()?.username)
        query.findObjectsInBackground { (objects, error) in
            if let error = error {
                print(error)
            } else if let object = objects?.first {
                
                if let obj = object as? PFObject {
                    print("Deleting: \(obj)")
                    obj.deleteInBackground(block: { (success, error) in
                        if error != nil {
                            print(error ?? "error while deleting")
                        } else {print("Object deleted")}
                    })
                } else {
                    print("failed to delete location object")
                }
            }
        }
    }
    
// Work on this next time
    func updateUserLocation(classN: String, id: String, location: CLLocation?) {
        let quiery = PFQuery(className: classN)
        quiery.getObjectInBackground(withId: id, block: { (object, error) in
            guard error == nil else {
                print(error ?? "Failed to fetch data")
                return
            }
                guard let newUserData = object else {
                    print("object doesnt exist")
                    return
                }
            newUserData["Location"] = PFGeoPoint(location: location)
            newUserData["UserName"] = PFUser.current()?.username
            newUserData.saveInBackground(block: { (sucess, error) in
                guard error == nil else {
                    print(error ?? "Failed to update data")
                    return
                }

            })
        })
    }
    
}

class UserData {
    var name = PFUser.current()?.username
    var password = PFUser.current()?.password
    var location = CLLocation()
    var objectID = String()
}
