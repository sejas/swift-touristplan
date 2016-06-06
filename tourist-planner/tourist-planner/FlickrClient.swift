//
//  FlickrClient.swift
//  tourist-planner
//
//  Created by Antonio Sejas on 6/6/16.
//  Copyright © 2016 Antonio Sejas. All rights reserved.
//

import UIKit
import CoreLocation

class FlickrClient: NSObject {
    //MARK: Constants
    struct Constants {
        // MARK: URLs
        static let BaseURL: String = "https://api.flickr.com/services/rest"
        static let ApiKey: String = "ff7dbadcbeff06fb9e1a9baf507703ab"
        static let MethodSearch: String = "flickr.photos.search"
        static let Extras: String = "url_m"
        static let Format: String = "json"
        static let Nojsoncallback: String = "1"
    }
    let commonParameters = [
        "api_key": Constants.ApiKey,
        "method": Constants.MethodSearch,
        "extras": Constants.Extras,
        "format": Constants.Format,
        "nojsoncallback": Constants.Nojsoncallback,
        ]
    
    //MARK: REST API Methods
    func searchPhotosByLocation(coordinates: CLLocationCoordinate2D, completionHandler: (result: AnyObject!, error: NSError?) -> Void){
        
        NetworkHelper.sharedInstance().postRequest(Constants.URLStudentLocations, headers: headersAuth, jsonBody: jsonBody, completionHandlerForPOST: completionHandler)
    }
    
    
    // MARK: Shared Instance
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    
}
