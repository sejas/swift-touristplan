//
//  CoreDataStackManager.swift
//  tourist-planner
//
//  Created by Antonio Sejas on 28/7/16.
//  Copyright © 2016 Antonio Sejas. All rights reserved.
//

import UIKit

class CoreDataStackManager: NSObject {
    let stack = CoreDataStack(modelName: "Model")!
    
}
// MARK - Singleton
extension CoreDataStackManager {
    // MARK: Shared Instance
    class func sharedInstance() -> CoreDataStackManager {
        struct Singleton {
            static var sharedInstance = CoreDataStackManager()
        }
        return Singleton.sharedInstance
    }
}