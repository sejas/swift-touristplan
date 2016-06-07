//
//  CustomAlert.swift
//  tourist-planner
//
//  Created by Antonio Sejas on 7/6/16.
//  Copyright © 2016 Antonio Sejas. All rights reserved.
//

import UIKit

class CustomAlert: NSObject {
    // Mark: General Helpers
    func showError(that: UIViewController, title: String, message: String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        performUIUpdatesOnMain({that.presentViewController(alertController, animated: true, completion: nil)})
    }
    // MARK: Shared Instance
    class func sharedInstance() -> CustomAlert {
        struct Singleton {
            static var sharedInstance = CustomAlert()
        }
        return Singleton.sharedInstance
    }
}
