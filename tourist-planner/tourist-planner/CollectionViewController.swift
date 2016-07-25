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
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    var placeAnnotation: Place!
    
    var imagesSelected = [NSIndexPath]()
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var collection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCollection()
        updateLocationsMap()
        if (self.fetchGallery()) {
            print("old pin with photos: \(placeAnnotation.photos.count)")
        } else {
            print("new pin without photos")
            getPhotosFlickrGeo(placeAnnotation!.coordinate)
        }
    }
    
    
    // MARK: MAP
    func updateLocationsMap() {
        //Delete old annotations if there were some
        performUIUpdatesOnMain({
            self.map.removeAnnotations(self.map.annotations)
        })
        //zoom
        let span = MKCoordinateSpanMake(0.0225, 0.0225);
        let region = MKCoordinateRegionMake(self.placeAnnotation!.coordinate, span);
        
        performUIUpdatesOnMain({
            // When the array is complete, we add the annotations to the map.
            self.map.addAnnotations([self.placeAnnotation])
            // self.map.setCenterCoordinate(self.annotation!.coordinate, animated: true)
            self.map.setRegion(region, animated: true)
        })
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = UIColor.blueColor()
            //false, because  when tap on pin we make a segue
            pinView!.canShowCallout = false
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
    func initCollection() {
        collection.allowsSelection = true
        collection.allowsMultipleSelection = true
        initFlowLayout()
    }
    //Set 3 cells per row
    func initFlowLayout() {
        let space:CGFloat = 3.0
        let dimension = (self.view.bounds.size.width - ( 2 * space )) / 2.0
        print("dimension: \(dimension), orientation: \(UIDevice.currentDevice().orientation.isPortrait), width: \(self.view.bounds.size.width)")
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.placeAnnotation.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //
        print("selected \(indexPath)")
        if let index = imagesSelected.indexOf(indexPath) {
            imagesSelected.removeAtIndex(index)
        }else{
            imagesSelected.append(indexPath)
        }
        self.collection.reloadData()
    }
    
    func setImageHolderAndDownloadImage(cell:CellPhotoCollectionViewCell, photoFlickr: PhotoFlickr) {
        let urlString = photoFlickr.url
        performUIUpdatesOnMain({
            cell.activity?.startAnimating()
            cell.activity?.hidden = false
            cell.img.image = UIImage(named: "placeholder-image")
        })
            FlickrClient.sharedInstance().downloadImage(urlString, completionHandler: { (image, error) in
                guard (error == nil) else {
                    performUIUpdatesOnMain({
                        //ERROR downloading image
                        cell.activity?.stopAnimating()
                        cell.activity?.hidden = true
                        cell.img.image = UIImage(named: "placeholder-image")
                    })
                    return
                }
                performUIUpdatesOnMain({
                    cell.activity?.stopAnimating()
                    cell.activity?.hidden = true
                    photoFlickr.image = image
                    cell.img.image = photoFlickr.image
                })
                
            })
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCellWithReuseIdentifier("cellPhoto", forIndexPath: indexPath) as! CellPhotoCollectionViewCell
        
        //I want to avoid show an old image in the cell
        //Maybe it should be in main queue?
        cell.img.image = nil
        
        //let urlString = self.placeAnnotation.photos[indexPath.row].url
        let photoFlickr = self.placeAnnotation.photos[indexPath.row] as! PhotoFlickr
        
        //If image in cache
        //if photoFlickr.image != nil {
        if let image = photoFlickr.image {
            cell.img.image = image
        }else{
            setImageHolderAndDownloadImage(cell, photoFlickr: photoFlickr)
        }
        
        if (imagesSelected.indexOf(indexPath) != nil) {
            cell.img.alpha = 0.3
        }else{
            cell.img.alpha = 1
        }

        return cell
    }
    
    
    //MARK: Network
    func getPhotosFlickrGeo(coordinates:CLLocationCoordinate2D) {
        
        deleteOldPhotos()
        
        FlickrClient.sharedInstance().searchPhotosByLocation(coordinates) { (result, error) in
            guard nil == error else {
                print("error searchPhotosByLocation",error)
                CustomAlert.sharedInstance().showError(self, title: "", message: "Error searching photos")
                return
            }
            print("searchPhotosByLocation count: ",result.count)
            guard let photosWrapper = result["photos"]!,
            let photos = photosWrapper["photo"] as? [AnyObject] else {
                return
            }
            for photo in photos {
                if (photo["url_m"] as? String) != nil {
                    //Create and save in coredata PhotoFlickr
                    let photoFlickr = PhotoFlickr(dictionary: photo as! [String : AnyObject], context: self.sharedContext)
                    photoFlickr.place = self.placeAnnotation
                    self.placeAnnotation.photos.addObject(photoFlickr)
                }
            }
            //TODO: reload collection
            performUIUpdatesOnMain({ 
                self.collection.reloadData()
            })
        }
    }
    // Coredata
    func fetchGallery() -> Bool {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error performing fetch")
            CustomAlert.sharedInstance().showError(self, title: "", message: error.localizedDescription)
        }
        print("fetchGallery count fetchedResultsController.fetchedObjects?.count \(fetchedResultsController.fetchedObjects?.count)")
        return 0 < fetchedResultsController.fetchedObjects?.count
        
    }
    // MARK: - Core Data Convenience
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    // Mark: - Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "PhotoFlickr")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "place == %@", self.placeAnnotation);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        
        return fetchedResultsController
        
    }()
    
    // Delete old photos to let create new album
    func deleteOldPhotos() {
        for photoFlickr in fetchedResultsController.fetchedObjects as! [PhotoFlickr] {
            sharedContext.deleteObject(photoFlickr)
        }
        // delate relation.
        // Question to test: The for is necesary? because we are using delete for cascade
        self.placeAnnotation.photos = NSMutableOrderedSet()
        
        
    }

}
