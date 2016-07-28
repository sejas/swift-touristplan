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
    
    @IBOutlet weak var barButtonNewCollectionRemove: UIBarButtonItem!
    
    
    var placeAnnotation: Place!
    
    var imagesSelected = [NSIndexPath]()
    
    enum uiStates: Int { case normal = 1, delete }
    var currentState = uiStates.normal
    
    let numberOfRandomPhotosLimit = 20
    
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
        
        updateUI()
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
    
    func updateUI() {
        if imagesSelected.count > 0 {
            currentState = .delete
            barButtonNewCollectionRemove.tintColor = UIColor.redColor()
            barButtonNewCollectionRemove.title = "Remove Selected Pictures"
        }else{
            currentState = .normal
            barButtonNewCollectionRemove.tintColor = self.view.tintColor
            barButtonNewCollectionRemove.title = "New Collection"
        }
        performUIUpdatesOnMain { 
            self.collection.reloadData()
        }
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
        self.updateUI()
    }
    
    func setImageHolderAndDownloadImage(cell:CellPhotoCollectionViewCell, photoFlickr: PhotoFlickr) {
        let urlString = photoFlickr.url
        performUIUpdatesOnMain({
            cell.activity?.startAnimating()
            cell.activity?.hidden = false
            cell.img.image = UIImage(named: "placeholder-image")
        })
            FlickrClient.sharedInstance().downloadImage(urlString, completionHandler: { (image, data, error) in
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
                    photoFlickr.imageData = data
                    cell.img.image = image
                })
                
            })
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCellWithReuseIdentifier("cellPhoto", forIndexPath: indexPath) as! CellPhotoCollectionViewCell
        
        //I want to avoid show an old image in the cell
        //Maybe it should be in main queue?
        cell.img.image = nil
        cell.activity.hidden = true
        
        //let urlString = self.placeAnnotation.photos[indexPath.row].url
        let photoFlickr = self.placeAnnotation.photos[indexPath.row] as! PhotoFlickr
        
        //If image in cache
        //if photoFlickr.image != nil {
        if let imageData = photoFlickr.imageData {
            cell.img.image = UIImage(data: imageData)
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
    
    //MARK: IBACTIONS New Collection Remove images
    // instead of save indexpath , I could save the photoFlickr object.
    func removeSelectedPictures() {
        var imagesToDelete = [PhotoFlickr]()
        for indexPath in imagesSelected {
            let photoFlickr = placeAnnotation.photos[indexPath.row] as! PhotoFlickr
            imagesToDelete.append(photoFlickr)
        }
        
        placeAnnotation.photos.removeObjectsInArray(imagesToDelete)
        for photoFlicker in imagesToDelete {
            sharedContext.deleteObject(photoFlicker)
        }
        
        CoreDataStackManager.sharedInstance().stack.save()
        
        imagesSelected.removeAll()
        updateUI()
    }
    @IBAction func actionNewCollection(sender: AnyObject) {
        if  currentState == .normal {
            getPhotosFlickrGeo(placeAnnotation!.coordinate)
        }else {
            //State is .delete
            removeSelectedPictures()
        }
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
            print("searchPhotosByLocation count: ",result.count,result)
            guard let photosWrapper = result["photos"]!,
            let photos = photosWrapper["photo"] as? [AnyObject] else {
                return
            }
            
            let limit = min(self.numberOfRandomPhotosLimit-1, photos.count-1)
            var randomNumbers = [Int]()
            for _ in 0...limit {
                let randomI = Int(arc4random_uniform(UInt32(photos.count)))
                let photo = photos[randomI]
                if nil == randomNumbers.indexOf(randomI)
                    && (photo["url_m"] as? String) != nil {
                    //If the random number/photo is not already in the collection and it has url
                    randomNumbers.append(randomI)
                    //Create and save in coredata PhotoFlickr
                    let photoFlickr = PhotoFlickr(dictionary: photo as! [String : AnyObject], context: self.sharedContext)
                    photoFlickr.place = self.placeAnnotation
                    self.placeAnnotation.photos.addObject(photoFlickr)
                }
            }
            
            performUIUpdatesOnMain({ 
                self.collection.reloadData()
                CoreDataStackManager.sharedInstance().stack.save()
            })
        }
    }
    
    // MARK: Coredata
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
        return CoreDataStackManager.sharedInstance().stack.context
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
        // Question to test: The for is necesary? because we are using delete for cascade
        for photoFlickr in fetchedResultsController.fetchedObjects as! [PhotoFlickr] {
            sharedContext.deleteObject(photoFlickr)
        }
        // delate relation.
        self.placeAnnotation.photos = NSMutableOrderedSet()
        
        
    }

}
