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
            if error != nil { print(error ?? "error while saving user location")
            }
            else {
                UserDefaults.standard.set(saveObject.objectId, forKey: "locationObjectId")
                print("New location object saved to server")
            }
        }
    }

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
    
    public func updateUserLocation(classN: String, id: String, location: CLLocation?) {
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
    
    func fetchUserData(userName: String) -> UserData? {
            let result = UserData()
            result.name = userName
            let query = PFUser.query()
            query?.findObjectsInBackground(block: { (objects, error) in
                guard error == nil else {
                    print(error ?? "error while fetching user names")
                    return
                }
                guard let users = objects else {
                    return
                }
                    for object in users {
                        guard let user = object as? PFUser else {
                        return }
                            if user.username == userName {
                                if let userInfo = user.value(forKey: "userInfo") as? String {
                                    result.userInfo = userInfo}
                                if let avatarPic = user.value(forKey: "avatar") as? PFFile {
                                    avatarPic.getDataInBackground { (imageData, error) in
                                        if error == nil {
                                            let image = UIImage(data:imageData!)
                                            result.avatar = image!
                                        }else{
                                            print(error ?? "error while fetching image")
                                        }
                                    }
                                }
                            }
                    }
            })
        return result
    }
    
    func findUsersLocation(userName: String) -> CLLocation? {
        
        let query = PFQuery(className: "Locations")
            query.whereKey("UserName", equalTo: userName)
        do {
            let objects: [PFObject] = try query.findObjects()
            if let object = objects.first {
            if let location = object["Location"] as? PFGeoPoint {
                return CLLocation(latitude: location.latitude, longitude: location.longitude)
                }
            }
        } catch {
            print("error while fetching location: \(error)")
        }
       return nil
    }
}

class UserData {
    var name = PFUser.current()?.username
    var password = PFUser.current()?.password
    var userInfo = String()
    var avatar = UIImage()
    var location = CLLocation()
    var objectID = String()
}
