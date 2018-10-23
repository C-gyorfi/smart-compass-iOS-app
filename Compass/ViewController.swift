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
    
    let ArrowImage = UIImageView(image: UIImage(named: "240px-Green_Arrow_Up_Darker.png"))
    let degreeLabel = UILabel(frame: CGRect.zero)
    let setTargetLocationButton = UIButton(frame: CGRect.zero)
    
    
    func initLocationManager() {
        
        //this function must be moved somewhere else, call once when app started
        //par.initParse(appID: "492795c6ea25112881915677092fb19d95f43ce0", clKey: "6c4448eb0dc5d344a0ca35f8d8f978ff82b76028", serverAddress: "http://18.188.82.67:80/parse")
        
        if let tempID = UserDefaults.standard.string(forKey: "parseObjectID") {
            myUserData.objectID = tempID
        } else { myUserData.objectID = "" }
        if let userName = UserDefaults.standard.string(forKey: "userName") {
            myUserData.name = userName
        } else { myUserData.objectID = "" }
        
        
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
    }
    
    func createUI(){
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        self.view.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.green]
        navigationItem.title = "No storyboard"
        degreeLabel.text = "Dir Degree->"
        self.view.addSubview(degreeLabel)
        self.view.addSubview(ArrowImage)
        
        setTargetLocationButton.setTitle("Set Target Location", for: .normal)
        setTargetLocationButton.addTarget(self, action: #selector(setTargetLocationPressed), for: .touchUpInside)
        self.view.addSubview(setTargetLocationButton)
        
        setTargetLocationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ setTargetLocationButton.centerXAnchor.constraint(lessThanOrEqualTo:     self.view.centerXAnchor),
                                      setTargetLocationButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 140)])
        
        degreeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ degreeLabel.centerXAnchor.constraint(lessThanOrEqualTo:self.view.centerXAnchor),
                                      degreeLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 100)])
        
        let backButton = UIButton(frame: CGRect.zero)
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        self.view.addSubview(backButton)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ backButton.centerXAnchor.constraint(lessThanOrEqualTo: self.view.centerXAnchor),
                                      backButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 300)])
        
        ArrowImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ArrowImage.widthAnchor.constraint(equalToConstant: 100),
                                     ArrowImage.heightAnchor.constraint(equalToConstant: 100),
                                     ArrowImage.centerXAnchor.constraint(lessThanOrEqualTo: self.view.centerXAnchor),
                                     ArrowImage.centerYAnchor.constraint(lessThanOrEqualTo: self.view.centerYAnchor)])
        
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
        print(UserDefaults.standard.string(forKey: "parseObjectID") as! String)
    }
    
    @objc func setTargetLocationPressed(_ sender: UIButton) {
        
        if currentLocation?.coordinate.latitude != nil && currentLocation?.coordinate.longitude != nil  {
            targetLocation = currentLocation
        print("New target location")
        }
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

