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
    
    //This feels unnecesarry for the sake of keeping all Parse related code in this class
    func logIn(userName: String, pass: String, completition: @escaping (PFUser?, Error?) -> Void) {
        PFUser.logInWithUsername(inBackground: userName, password: pass) { (user, error) in
            guard error == nil else {
                completition (nil, error)
                return
            }
            completition(user, nil)
            return
        }
    }
        
    func saveNewLocation(classN: String, uData: UserData) {
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
                    self.saveNewLocation(classN: classN, uData: uData)
            }
        }
    }
    
//    func deleteObjects(classN: String) {
//        let query = PFQuery(className: classN)
//        query.whereKey("UserName", equalTo: PFUser.current()?.username)
//        query.findObjectsInBackground { (objects, error) in
//            if let error = error {
//                print(error)
//            } else if let object = objects?.first {
//                    object.deleteInBackground(block: { (success, error) in
//                        if error != nil {
//                            print(error ?? "error while deleting")
//                        } else {print("Object deleted")}
//                    })
//            }
//        }
//    }
    
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
    
    func fetchUserList(completition: @escaping ([String]?, Error?) -> Void) {
        let query = PFUser.query()
        query?.findObjectsInBackground(block: { (objects, error) in
            var result = [String]()
            guard error == nil else {
                completition(nil, error)
                return
            }
            if let users = objects {
                for object in users {
                    if let user = object as? PFUser {
                        if user.username != PFUser.current()?.username {
                            result.append(user.username!)
                        }
                    }
                }
                completition(result, nil)
            }
        })
    }
    
    // Using closure expression (block synthax) to work around the threding issue
    func fetchUserData(userName: String, completion: @escaping (UserData?, Error?) -> Void) {
            let result = UserData()
            result.name = userName
            let query = PFUser.query()
            query?.findObjectsInBackground(block: { (objects, error) in
                guard error == nil else {
                    print(error ?? "error while fetching user names")
                    completion(nil, error)
                    return
                }
                guard let users = objects else {
                    completion(nil, nil)
                    return
                }
                    for object in users {
                        guard let user = object as? PFUser else {
                            completion(nil, nil)
                            return
                        }
                        if user.username == userName {
                            if let userInfo = user.value(forKey: "userInfo") as? String {
                                result.userInfo = userInfo}
                            if let avatarPic = user.value(forKey: "avatar") as? PFFile {
                                avatarPic.getDataInBackground { (imageData, error) in
                                    if error == nil {
                                        let image = UIImage(data:imageData!)
                                        result.avatar = image!
                                        completion(result, nil)
                                    }else{
                                        print(error ?? "error while fetching image")
                                    }
                                }
                            }
                        }
                    }
            })
    }
    
    // Solution that runs on Main thread
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
