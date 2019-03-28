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
    let targetLabel = UILabel(frame: CGRect.zero)
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
        self.targetLocation = nil
        guard let targerUserName = UserDefaults.standard.string(forKey: "targetUserName") else {
            return
        }
        self.targetLocation = par.findUsersLocation(userName: targerUserName)
    }
    
    private func createUI(){
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        self.view.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.green]
        navigationItem.title = "Compass"
        self.view.addSubview(degreeLabel)
        self.view.addSubview(distanceLabel)
        self.view.addSubview(ArrowImage)
        
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
            let dirRadiant = Calculations.degreesToRadians(degrees: Calculations.getBearingBetweenTwoPoints1(point1: currentLocation!, point2: targetLocation!))
            
            UIView.animate(withDuration: 0.5) {
                self.ArrowImage.transform = CGAffineTransform(rotationAngle: CGFloat(dirRadiant - headingR))
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations[0]
        myUserData.location = locations[0]
        par.updateUserLocation(classN: "Locations", id: myUserData.objectID, location: myUserData.location)
        
        guard let targetLocation = targetLocation,
              let distance = currentLocation?.distance(from: targetLocation) else {
            return
        }
        if (distance > 1000) {
            distanceLabel.text = "Distance: \(Int(distance/1000))km"
        } else {
            distanceLabel.text = "Distance: \(Int(distance))m"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

