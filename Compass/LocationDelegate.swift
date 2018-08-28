//
//  LocationDelegate.swift
//  Compass
//
//  Created by Csabi on 21/08/2018
//  Copyright © 2018 Csaba Gyorfi. All rights reserved.


import Foundation
import CoreLocation
import UIKit

class LocationDelegate: NSObject, CLLocationManagerDelegate {

    
    
    var locationCallback: ((CLLocation) -> ())? = nil
    var headingCallback: ((CLLocationDirection) ->())? = nil
    
    
    func locatonManager(_ manager: CLLocationManager, didUodateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {return}
        locationCallback?(currentLocation)
        
        func getRadian(_ destinationLocation: CLLocation) -> CGFloat {
            

            return CGFloat(1);
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
    }
    
}
