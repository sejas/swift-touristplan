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

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get locations from api
        //        getParseLocationsAndRefreshMap()
        
        getRandomPhotos()
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
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            //            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.blueColor()
            //            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
            pinView!.canShowCallout = false //false, because  when tap on pin we make a segue
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
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
        let touchPoint = sender.locationInView(map)
        let newCoordinates = map.convertPoint(touchPoint, toCoordinateFromView: map)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        
        map.addAnnotation(annotation)
    }
    
    //Segue
    func mapView(mapView: MKMapView,didSelectAnnotationView view: MKAnnotationView){
        print("tapped and annotation",view)
        performSegueWithIdentifier("toCollectionView", sender: view.annotation)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if ("toCollectionView" == segue.identifier!) {
            let v = segue.destinationViewController as! CollectionViewController
            let a = sender as? MKAnnotation
            v.placeAnnotation = Place(latitude: (a?.coordinate.latitude)!, longitude: (a?.coordinate.longitude)!, context: sharedContext)
        }
    }
    
    // MARK: - Core Data Convenience
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
}

