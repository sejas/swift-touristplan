//
//  CoreDataStackManager.swift
//  tourist-planner
//
//  Created by Antonio Sejas on 28/7/16.
//  Copyright © 2016 Antonio Sejas. All rights reserved.
//

import UIKit

class CoreDataStackManager: NSObject {
    // MARK: Shared Instance Singleton
    static let sharedInstance = CoreDataStackManager()
    
    let stack = CoreDataStack(modelName: "Model")!
    
}