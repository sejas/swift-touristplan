//
//  PhotoFlikr.swift
//  tourist-planner
//
//  Created by Antonio Sejas on 15/6/16.
//  Copyright © 2016 Antonio Sejas. All rights reserved.
//

import UIKit
import CoreData

class PhotoFlickr: NSManagedObject {

    @NSManaged var place: Place
    @NSManaged var url: String
    @NSManaged var id: String
    
    struct Keys {
        static let url = "url_m"
        static let id = "id"
    }
    

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary:[String:AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("PhotoFlickr", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        id = dictionary[Keys.id] as! String
        url = dictionary[Keys.url] as! String
    }
    
    override func prepareForDeletion() {
        // delete image from memory
        FlickrClient.Caches.imageCache.storeImage(nil, withIdentifier: self.id)
    }
    
    
    
}
