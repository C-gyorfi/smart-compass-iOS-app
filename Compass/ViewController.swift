//
//  ViewController.swift
//  Compass
//
//  Created by Csabi on 20/08/2018.
//  Copyright © 2018 Csaba Gyorfi. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation? = nil;
    
    @IBOutlet weak var ArrowImage: UIImageView!
    @IBOutlet weak var degreeLabel: UITextField!
    
    @IBAction func popLocationButton(_ sender: UIButton) {
        
        var latitude: CLLocationDegrees;
        var longitude: CLLocationDegrees;
        
        if currentLocation?.coordinate.latitude != nil {
         
            latitude = currentLocation!.coordinate.latitude
            
            if currentLocation?.coordinate.longitude != nil {
                
                longitude = currentLocation!.coordinate.longitude
                let userLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                print(userLocation.latitude)
                print(userLocation.longitude)
            }
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
        
        let radiants = Measurement(value: newHeading.trueHeading, unit: UnitAngle.degrees).converted(to: .radians).value
        
        UIView.animate(withDuration: 0.5) {
            self.ArrowImage.transform = CGAffineTransform(rotationAngle: CGFloat(6.28-radiants))
        }
        degreeLabel.text = String(newHeading.trueHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations[0];
        
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

