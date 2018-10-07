//
//  ViewController.swift
//  Compass
//
//  Created by Csabi on 20/08/2018.
//  Copyright © 2018 Csaba Gyorfi. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation? = nil
    var targetLocation: CLLocation? = nil
    let par = PServer()
    let myCalc = Calculations()
    var myUserData = UserData()
    
    @IBOutlet weak var ArrowImage: UIImageView!
    @IBOutlet weak var degreeLabel: UITextField!
    
    @IBAction func popLocationButton(_ sender: UIButton) {
        
        if currentLocation?.coordinate.latitude != nil && currentLocation?.coordinate.longitude != nil  {
            targetLocation = currentLocation
        }
    }
    
    func initLocationManager() {
        
        par.initParse(appID: "492795c6ea25112881915677092fb19d95f43ce0", clKey: "6c4448eb0dc5d344a0ca35f8d8f978ff82b76028", serverAddress: "http://18.188.82.67:80/parse")
        
        //This code will go to login page ViewController
        myUserData.name = "Test Name"
        par.saveUserLocation(classN: "Users", uData: myUserData)
        if let tempID = UserDefaults.standard.string(forKey: "parseObjectID") {
            myUserData.objectID = tempID
        } else { myUserData.objectID = "NoID" }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //this is a ratiant value indicates phone's direction in relation to true north(0)
        let headingR = Measurement(value: newHeading.trueHeading, unit: UnitAngle.degrees).converted(to: .radians).value
        
        //if target is nil, arrow will point to north
        if targetLocation == nil {
        UIView.animate(withDuration: 0.5) {
        self.ArrowImage.transform = CGAffineTransform(rotationAngle: CGFloat(6.28-headingR))
        }
        degreeLabel.text = String(newHeading.trueHeading)
        }
        
        else {
            //need to use newHeading to calculate headin in realation to point
            let dirRadiant = self.myCalc.degreesToRadians(degrees: myCalc.getBearingBetweenTwoPoints1(point1: currentLocation!, point2: targetLocation!))
            
            UIView.animate(withDuration: 0.5) {
                //now it should point towards the target location in case the device points towards north -> test this
                self.ArrowImage.transform = CGAffineTransform(rotationAngle: CGFloat(dirRadiant - headingR))
            }
            degreeLabel.text = String(dirRadiant)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations[0]
        myUserData.location = locations[0]
            if par.updateUserLocation(classN: "Users", uData: myUserData) {
                print("Current object id = \(myUserData.objectID)")
            } else {
                if let tempID = UserDefaults.standard.string(forKey: "parseObjectID") {
                myUserData.objectID = tempID
                    }
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

