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
        
        static let spanCoordinateLat: String = "mapSpanCoordinateLat"
        static let spanCoordinateLong: String = "mapSpanCoordinateLong"

    }
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    
    func saveCenterCoordinates(coordinates: CLLocationCoordinate2D)  {
        prefs.setObject(NSNumber(double: coordinates.latitude), forKey: Constants.centerCoordinateLat)
        prefs.setObject(NSNumber(double: coordinates.longitude), forKey: Constants.centerCoordinateLong)
    }
    func saveSpanCoordinates(coordinates: MKCoordinateSpan)  {
        prefs.setObject(NSNumber(double: coordinates.latitudeDelta), forKey: Constants.spanCoordinateLat)
        prefs.setObject(NSNumber(double: coordinates.longitudeDelta), forKey: Constants.spanCoordinateLong)
    }
    func getCenterCoordinates() -> MKCoordinateRegion? {
        guard let lat = prefs.objectForKey(Constants.centerCoordinateLat),
            let long = prefs.objectForKey(Constants.centerCoordinateLong),
            let latSpan = prefs.objectForKey(Constants.spanCoordinateLat),
            let longSpan = prefs.objectForKey(Constants.spanCoordinateLong) else {
            return nil
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat.doubleValue, longitude:long.doubleValue), span: MKCoordinateSpan(latitudeDelta: latSpan.doubleValue, longitudeDelta: longSpan.doubleValue))
    }
    
    
    // MARK: Shared Instance
    class func sharedInstance() -> UserDefaults {
        struct Singleton {
            static var sharedInstance = UserDefaults()
        }
        return Singleton.sharedInstance
    }
}
