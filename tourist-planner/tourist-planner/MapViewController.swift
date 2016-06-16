//
//  ViewController.swift
//  tourist-planner
//
//  Created by Antonio Sejas on 5/6/16.
//  Copyright © 2016 Antonio Sejas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get locations from api
        //        getParseLocationsAndRefreshMap()
        
        print("fetchedLocations = \(self.fetchPlaces())")
        print("count = \(self.fetchPlaces().count)")
        
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    // MARK: MAP
    func updateLocationsMap() {
        //Delete old annotations if there were some
        performUIUpdatesOnMain({
            self.map.removeAnnotations(self.map.annotations)
        })
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
        
        // The "locations" array is loaded with the sample data below. We are using the dictionaries
        // to create map annotations. This would be more stylish if the dictionaries were being
        // used to create custom structs. Perhaps StudentLocation structs.
        
        //        for oneLocation in StudentLocations.sharedInstance().locations {
        //
        //            // Here we create the annotation and set its coordiate, title, and subtitle properties
        //            let annotation = MKPointAnnotation()
        //            annotation.coordinate = oneLocation.coordinate
        //            annotation.title = "\(oneLocation.firstName) \(oneLocation.lastName)"
        //            annotation.subtitle = oneLocation.mediaURL
        //
        //            // Finally we place the annotation in an array of annotations.
        //            annotations.append(annotation)
        //        }
        
        performUIUpdatesOnMain({
            // When the array is complete, we add the annotations to the map.
            self.map.addAnnotations(annotations)
        })
    }
    
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
//        let reuseId = "pin"
//        
//        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
//        
//        if pinView == nil {
//            let place = Place(coordinate: annotation.coordinate, context: sharedContext )
//            pinView = MKPinAnnotationView(annotation: place, reuseIdentifier: reuseId)
//            //            pinView!.canShowCallout = true
//            pinView!.pinTintColor = UIColor.blueColor()
//            //            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
//            
//            pinView!.canShowCallout = false //false, because  when tap on pin we make a segue
//        }
//        else {
//            pinView!.annotation = annotation
//        }
//        
//        return pinView
        if let annotation = annotation as? Place {
            let identifier = "pin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            }
            else{
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                view.animatesDrop = true
                view.draggable = false
                
            }
            return view
        }
        return nil

    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped tapped and annotation",view)
    }
    
    //
    //    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
    //        print("tapped and annotation",view)
    //    }
    
    
    //MARK: Network
    func getRandomPhotos() {
//        let coordinates = CLLocationCoordinate2D(latitude: 28.124904, longitude: -15.428243)
//        FlickrClient.sharedInstance().searchPhotosByLocation(coordinates) { (result, error) in
//            guard nil == error else {
//                print("error searchPhotosByLocation",error)
//                CustomAlert.sharedInstance().showError(self, title: "", message: "Error searching photos")
//                return
//            }
//            print("searchPhotosByLocation",result)
//        }
    }
    
    
    //MARK: Gestures
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    @IBAction func actionGestureLongPress(sender: UILongPressGestureRecognizer) {
//        let touchPoint = sender.locationInView(map)
//        let newCoordinates = map.convertPoint(touchPoint, toCoordinateFromView: map)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = newCoordinates
//        
//        
//        map.addAnnotation(annotation)
        
        // get referance to long press coords
        let touchPoint = sender.locationInView(map)
        let newCoordinates = map.convertPoint(touchPoint, toCoordinateFromView: map)
        
        switch sender.state {
        case .Began:
            // create the location
            let placeToBeAdded = Place(coordinate: newCoordinates, context: sharedContext)
            map.addAnnotation(placeToBeAdded)
            
        case .Changed:
            // update coordinate on drag
            //https://discussions.udacity.com/t/how-can-i-make-a-new-pin-draggable-right-after-adding-it/26653
//            locationToBeAdded!.willChangeValueForKey("coordinate")
//            locationToBeAdded!.coordinate = newCoordinates
//            locationToBeAdded!.didChangeValueForKey("coordinate")
            break
        case .Ended:
            
            // save in completion handler??????
//            FlickrClient.sharedInstance().fetchPhotosForLocation(locationToBeAdded!) { }
            CoreDataStackManager.sharedInstance().saveContext()
            print("count = \(self.fetchPlaces().count)")
            
        default:
            return
        }

    }
    
    //Segue
    func mapView(mapView: MKMapView,didSelectAnnotationView view: MKAnnotationView){
        print("tapped and annotation",view)
        let place = view.annotation as! Place
        performSegueWithIdentifier("toCollectionView", sender: place)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if ("toCollectionView" == segue.identifier!) {
            let v = segue.destinationViewController as! CollectionViewController
            let a = sender as? Place
//            v.placeAnnotation = Place(latitude: (a?.coordinate.latitude)!, longitude: (a?.coordinate.longitude)!, context: sharedContext)
            v.placeAnnotation = a
        }
    }
    
    // MARK: - Core Data Convenience
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    //MARK: - Core Data Fetch Places
    
    func fetchPlaces() -> [Place] {
        let error: NSError? = nil
        
        var results: [AnyObject]?
        let fetchRequest = NSFetchRequest(entityName: "Place")
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch error! as NSError {
            results = nil
        } catch _ {
            results = nil
        }
        
        if error != nil {
            print("Can not access previous locations")
        }
        return results as! [Place]
    }
    
}

