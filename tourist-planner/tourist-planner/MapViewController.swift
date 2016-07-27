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
    
    var locations:[Place] = []
    var placeToBeAdded : Place? = nil
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get locations from api
        print("Fetched places count: \(self.fetchPlaces().count)")
        locations = self.fetchPlaces()
        updateLocationsMap()
        
        
        //Show the last place you were viewing
        if let savedRegion = UserDefaults.sharedInstance().getCenterCoordinates() {
            //map.setRegion(savedRegion, animated: false)
            print(savedRegion)
        }
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
        
        performUIUpdatesOnMain({
            // When the array is complete, we add the annotations to the map.
            self.map.addAnnotations(self.locations)
        })
    }
    
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
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
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.sharedInstance().saveCenterCoordinates(mapView.centerCoordinate)
        UserDefaults.sharedInstance().saveSpanCoordinates(mapView.region.span)
    }
    
    
    //MARK: Gestures
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    @IBAction func actionGestureLongPress(sender: UILongPressGestureRecognizer) {
        // get referance to long press coords
        let touchPoint = sender.locationInView(map)
        let newCoordinates = map.convertPoint(touchPoint, toCoordinateFromView: map)
        
        switch sender.state {
        case .Began:
            // create the location
            placeToBeAdded = Place(coordinate: newCoordinates, context: sharedContext)
            map.addAnnotation(placeToBeAdded!)
            
        case .Changed:
            //https://discussions.udacity.com/t/how-can-i-make-a-new-pin-draggable-right-after-adding-it/26653
            // let move the place when drag
            placeToBeAdded!.willChangeValueForKey("coordinate")
            placeToBeAdded!.coordinate = newCoordinates
            placeToBeAdded!.didChangeValueForKey("coordinate")
            break
        case .Ended:
            // save in coredata
            CoreDataStackManager.sharedInstance().saveContext()
            print("count = \(self.fetchPlaces().count)")
            
        default:
            return
        }
        
    }
    
    
    //Segue
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView){
        print("tapped and annotation",view)
        self.map.deselectAnnotation(view.annotation, animated: false)
        let place = view.annotation as! Place
        performSegueWithIdentifier("toCollectionView", sender: place)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if ("toCollectionView" == segue.identifier!) {
            let v = segue.destinationViewController as! CollectionViewController
            v.placeAnnotation = sender as? Place
        }
    }
    
    // MARK: - Core Data Convenience
    
    
    //MARK: - Core Data Fetch Places
    
    func fetchPlaces() -> [Place] {
        let error: NSError? = nil
        
        var results: [AnyObject]?
        let fetchRequest = NSFetchRequest(entityName: "Place")
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch _ {
            results = nil
        }
        
        if error != nil {
            print("Can not access previous locations")
        }
        return results as! [Place]
    }
    
}

