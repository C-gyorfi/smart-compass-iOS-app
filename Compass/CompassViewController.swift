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

class CompassViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var targetLocation: CLLocation?
    let par = PServer()
    let myCalc = Calculations()
    var myUserData = UserData()
    
    let ArrowImage = UIImageView(image: UIImage(named: "240px-Green_Arrow_Up_Darker.png"))
    let degreeLabel = UILabel(frame: CGRect.zero)
    let distanceLabel = UILabel(frame: CGRect.zero)
    let setTargetLocationButton = UIButton(frame: CGRect.zero)
    let backButton = UIButton(frame: CGRect.zero)
    
    
    func initLocationManager() {
        if let userName = UserDefaults.standard.string(forKey: "userName") {
            myUserData.name = userName
        }
        if let objectID = UserDefaults.standard.string(forKey: "locationObjectId") {
            myUserData.objectID = objectID
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        createUI()
        setUpHandlers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //get location object for user
        //problem with this: slowing down the main thread
        //solution: keep the background operation, but instead of returning a value, save value in a public var
        //start tracking when this public var is != nil
        self.targetLocation = nil
        if let targerUserName = UserDefaults.standard.string(forKey: "targetUserName") {
           self.targetLocation = par.findUsersLocation(userName: targerUserName)
        }
    
//        let query = PFQuery(className: "Locations")
//        if let targerUserName = UserDefaults.standard.string(forKey: "targetUserName") {
//            query.whereKey("UserName", equalTo: targerUserName)
//            query.findObjectsInBackground { (objects, error) in
//                if let error = error {
//                    print(error)
//                } else if let object = objects?.first {
//
//                    if let location = object["Location"] as? PFGeoPoint {
//                        self.targetLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
//                        print("new target location: \(self.targetLocation)")
//                    } else {
//                        print("failed to update target")
//                    }
//                }
//            }
//        }
    }
    
    private func createUI(){
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        self.view.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.green]
        navigationItem.title = "Compass"
        degreeLabel.text = "Dir Degree->"
        distanceLabel.text = "Calculating distance..."
        self.view.addSubview(degreeLabel)
        self.view.addSubview(distanceLabel)
        self.view.addSubview(ArrowImage)
        
        //setTargetLocationButton.setTitle("Set Target Location", for: .normal)
        //self.view.addSubview(setTargetLocationButton)
//        setTargetLocationButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([ setTargetLocationButton.centerXAnchor.constraint(lessThanOrEqualTo:     self.view.centerXAnchor),
//                                      setTargetLocationButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 140)])
        
        degreeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ degreeLabel.centerXAnchor.constraint(lessThanOrEqualTo:self.view.centerXAnchor),
                                      degreeLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -100)])
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ distanceLabel.centerXAnchor.constraint(lessThanOrEqualTo:self.view.centerXAnchor),
                                      distanceLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 100)])
        
        backButton.setTitle("Back", for: .normal)
        self.view.addSubview(backButton)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ backButton.centerXAnchor.constraint(lessThanOrEqualTo: self.view.centerXAnchor),
                                      backButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 180)])
        
        ArrowImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ArrowImage.widthAnchor.constraint(equalToConstant: 100),
                                     ArrowImage.heightAnchor.constraint(equalToConstant: 100),
                                     ArrowImage.centerXAnchor.constraint(lessThanOrEqualTo: self.view.centerXAnchor),
                                     ArrowImage.centerYAnchor.constraint(lessThanOrEqualTo: self.view.centerYAnchor)])
        
    }
    
    private func setUpHandlers() {
        setTargetLocationButton.addTarget(self, action: #selector(setTargetLocationPressed), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func setTargetLocationPressed(_ sender: UIButton) {
        if currentLocation?.coordinate.latitude != nil && currentLocation?.coordinate.longitude != nil  {
            targetLocation = currentLocation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //this is a ratiant value indicates phone's direction in relation to true north(0)
        let headingR = Measurement(value: newHeading.trueHeading, unit: UnitAngle.degrees).converted(to: .radians).value
        
        degreeLabel.text = "\(Int(newHeading.trueHeading))°"
        
        //if target is nil, arrow will point to true north
        if targetLocation == nil {
        UIView.animate(withDuration: 0.5) {
        self.ArrowImage.transform = CGAffineTransform(rotationAngle: CGFloat(6.28-headingR))
            }
        } else {
            //need to use newHeading to calculate headin in realation to target point
            let dirRadiant = self.myCalc.degreesToRadians(degrees: myCalc.getBearingBetweenTwoPoints1(point1: currentLocation!, point2: targetLocation!))
            
            UIView.animate(withDuration: 0.5) {
                self.ArrowImage.transform = CGAffineTransform(rotationAngle: CGFloat(dirRadiant - headingR))
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations[0]
        myUserData.location = locations[0]
        par.updateUserLocation(classN: "Locations", id: myUserData.objectID, location: myUserData.location)
        
        guard let targetLocation = targetLocation else {
            return
        }
        if let distance = currentLocation?.distance(from: targetLocation) {
            distanceLabel.text = "\(Int(distance))m"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

