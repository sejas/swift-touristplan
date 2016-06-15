//
//  CollectionViewController.swift
//  tourist-planner
//
//  Created by Antonio Sejas on 9/6/16.
//  Copyright © 2016 Antonio Sejas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,MKMapViewDelegate {
    var placeAnnotation: Place!
    var photos: [String] = []
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var collection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLocationsMap()
        getPhotosFlickrGeo(placeAnnotation!.coordinate)
    }
    
    
    // MARK: MAP
    func updateLocationsMap() {
        //Delete old annotations if there were some
        performUIUpdatesOnMain({
            self.map.removeAnnotations(self.map.annotations)
        })

        var annotations = [MKAnnotation]()
        annotations.append(self.placeAnnotation!)
        
        
        //zoom
        let span = MKCoordinateSpanMake(0.0225, 0.0225);
        let region = MKCoordinateRegionMake(self.placeAnnotation!.coordinate, span);
        
        performUIUpdatesOnMain({
            // When the array is complete, we add the annotations to the map.
            self.map.addAnnotations(annotations)
            // self.map.setCenterCoordinate(self.annotation!.coordinate, animated: true)
            self.map.setRegion(region, animated: true)
        })
    }
    
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
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped tapped and annotation",view)
    }

    // MARK: Collection
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCellWithReuseIdentifier("cellPhoto", forIndexPath: indexPath) as! CellPhotoCollectionViewCell
        
        if let urlString = photos[indexPath.row] as? String,
            let url = NSURL(string: urlString) {
            if let data = NSData(contentsOfURL: url) {
                performUIUpdatesOnMain({ 
                    cell.img.image = UIImage(data: data)
                })
            }
        }else{
            cell.img.image = UIImage(named: "placeholder-image")
        }
        return cell
    }
    
    //MARK: Network
    func getPhotosFlickrGeo(coordinates:CLLocationCoordinate2D) {
        // let coordinates = CLLocationCoordinate2D(latitude: 28.124904, longitude: -15.428243)
        FlickrClient.sharedInstance().searchPhotosByLocation(coordinates) { (result, error) in
            guard nil == error else {
                print("error searchPhotosByLocation",error)
                CustomAlert.sharedInstance().showError(self, title: "", message: "Error searching photos")
                return
            }
            print("searchPhotosByLocation",result)
            guard let photosWrapper = result["photos"]!,
            let photos = photosWrapper["photo"] as? [AnyObject] else {
                    
                return
            }
            for photo in photos {
                if let url = photo["url_m"] as? String {
                    self.photos.append(url)
                }
            }
            //TODO: reload collection
            self.collection.reloadData()
        }
    }
    
    // MARK: - Core Data Convenience
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    // Mark: - Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "PhotoFlickr")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "place == %@", self.placeAnnotation);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()

}
