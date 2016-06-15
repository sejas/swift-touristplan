//
//  Place.swift
//  tourist-planner
//
//  Created by Antonio Sejas on 15/6/16.
//  Copyright © 2016 Antonio Sejas. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class Place: NSManagedObject, MKAnnotation {
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos:[PhotoFlickr]?
    
    struct Keys {
        static let latitude = "url_m"
        static let longitude = "longitude"
    }
    

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary:[String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Place", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = dictionary[Keys.latitude] as! Double
        longitude = dictionary[Keys.longitude] as! Double
        
    }
    
    init(latitude:Double, longitude:Double, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("Place", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.latitude = latitude
        self.longitude = longitude
        
    }
    
}
