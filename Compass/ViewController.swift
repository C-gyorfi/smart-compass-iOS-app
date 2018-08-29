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

    @IBOutlet weak var ArrowImage: UIImageView!
    @IBOutlet weak var degreeLabel: UITextField!
    
    var locationManager = CLLocationManager()
   
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
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

