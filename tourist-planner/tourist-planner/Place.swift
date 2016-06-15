//
//  Place.swift
//  tourist-planner
//
//  Created by Antonio Sejas on 15/6/16.
//  Copyright © 2016 Antonio Sejas. All rights reserved.
//

import UIKit
import CoreData

class Place: NSManagedObject {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var photos:[PhotoFlickr]?
    
    
}
