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
    let myCalc = Calculations()
    
    @IBOutlet weak var ArrowImage: UIImageView!
    @IBOutlet weak var degreeLabel: UITextField!
    

    @IBAction func popLocationButton(_ sender: UIButton) {
        
        if currentLocation?.coordinate.latitude != nil && currentLocation?.coordinate.longitude != nil  {
         
            targetLocation = currentLocation
        }
    }
    
    func initLocationManager() {
        
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
                self.ArrowImage.transform = CGAffineTransform(rotationAngle: CGFloat((6.28 - headingR) + dirRadiant))
            }
            
            degreeLabel.text = String(dirRadiant)
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations[0]
        if currentLocation != nil {
            let point = PFGeoPoint (location: currentLocation)
            saveToParseServer(classN: "Loc", key: "userName", data: point)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //this needs to go in a new file, what's the best to do this?
    func saveToParseServer(classN: String, key: String, data: Any) {
        let saveObject = PFObject(className: classN)
        saveObject[key] = data
        saveObject.saveInBackground { (success, error) -> Void in
                print("SAVED!!!!")
        }
    }
}

