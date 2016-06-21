//
//  Place.swift
//  tourist-planner
//
//  Created by Antonio Sejas on 15/6/16.
//  Copyright © 2016 Antonio Sejas. All rights reserved.
//
import CoreData
import MapKit

class Place: NSManagedObject, MKAnnotation{
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: NSMutableOrderedSet
    
    
    struct Keys {
        static let place = "Place"
        static let longitude = "longitude"
        static let latitude = "latitude"
    }
    
    // conform to MKAnnotation
    var coordinate: CLLocationCoordinate2D {
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }        
        get {
            return CLLocationCoordinate2DMake(latitude, longitude)
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        
        // Core Data
        let entity = NSEntityDescription.entityForName(Keys.place, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        self.photos = NSMutableOrderedSet()
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName(Keys.place, inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        if let latitude = dictionary[Keys.latitude] as! Double? {
            if let longitude = dictionary[Keys.longitude] as! Double? {
                self.latitude = latitude
                self.longitude = longitude
            }
        }
        self.photos = NSMutableOrderedSet()
    }
    
    //MARK: override DESCRIPTION
    override var description: String {
        return String("Location: \(latitude), \(longitude)")
    }
    
}

//MARK: == Operator
// isEqual
func ==(lhs: Place, rhs: Place) -> Bool {
    return (lhs.latitude == rhs.latitude) && (lhs.longitude == rhs.longitude)
}