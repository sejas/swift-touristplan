//
//  userDefaults.swift
//  tourist-planner
//
//  Created by Antonio Sejas on 27/7/16.
//  Copyright © 2016 Antonio Sejas. All rights reserved.
//

import UIKit
import MapKit

class UserDefaults: NSObject {

    
    struct Constants {
        // MARK: Preferences keys
        static let centerCoordinateLat: String = "mapCenterCoordinateLat"
        static let centerCoordinateLong: String = "mapCenterCoordinateLong"
    }
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    
    func saveCenterCoordinates(coordinates: CLLocationCoordinate2D)  {
        prefs.setObject(NSNumber(double: coordinates.latitude), forKey: Constants.centerCoordinateLat)
        prefs.setObject(NSNumber(double: coordinates.latitude), forKey: Constants.centerCoordinateLong)
    }
    func getCenterCoordinates() -> CLLocationCoordinate2D? {
        guard let lat = prefs.objectForKey(Constants.centerCoordinateLat),
            let long = prefs.objectForKey(Constants.centerCoordinateLat) else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: long.doubleValue)
    }
    
    
    // MARK: Shared Instance
    class func sharedInstance() -> UserDefaults {
        struct Singleton {
            static var sharedInstance = UserDefaults()
        }
        return Singleton.sharedInstance
    }
}
