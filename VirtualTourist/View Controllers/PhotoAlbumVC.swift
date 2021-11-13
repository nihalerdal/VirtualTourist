//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Nihal Erdal on 9/10/21.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController , MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var renewButton: UIButton!
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout!{
        didSet {
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    
    var photo: Photo!
    var pin: Pin!
    
    var dataController : DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        renewButton.isEnabled = false
        setupFetchedResultsController()
        getPhotos()
        setupMap()
    }
    
    @IBAction func newCollection(_ sender: Any) {
        
        renewButton.isEnabled = false
        
        if let album  = fetchedResultsController.fetchedObjects{
            for photo in album {
                dataController.viewContext.delete(photo)
            }
        }
        getPhotos()
        collectionView.reloadData()
        renewButton.isEnabled = true
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if  pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.tintColor = .red
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        setupFetchedResultsController()
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        let aPhoto = fetchedResultsController.object(at: indexPath)
        
        renewButton.isEnabled = false
        cell.activityIndicator.startAnimating()
        
        
        if let url = aPhoto.url{
            if let image = aPhoto.image{
                cell.imageView.image = UIImage(data: image)
            }else{
                
                FlickerClient.downloadPhotos(imageURL: URL(string: (url))!) { data, error in
                    
                    if let data = data {
                        let image = UIImage(data: data)
                        aPhoto.image = data
                        cell.imageView.image = image
                        
                        do {
                            try self.dataController.viewContext.save()
                        } catch {
                            fatalError("Unable to save photos: \(error.localizedDescription)")
                        }
                        
                    } else {
                        fatalError("error:\(error?.localizedDescription)")
                    }
                }
            }
            cell.activityIndicator.isHidden = true
            cell.activityIndicator.stopAnimating()
            self.renewButton.isEnabled = true
        }else{
            
            let placeholderImage = UIImage(systemName: "photo")
            cell.imageView.image = placeholderImage
        }
        return cell
    }
    
    
    
    
    func getPhotos(){
        
        if fetchedResultsController.fetchedObjects!.count == 0 {
            renewButton.isEnabled = false
            FlickerClient.getPhotos(latitude: pin.latitude, longitude: pin.longitude) { response, error in
                if error == nil && response?.photos.photo != nil {
                    guard let response = response else {return}
                    for image in response.photos.photo{
                        let photo = Photo(context: self.dataController.viewContext)
                        photo.creationDate = Date()
                        photo.url = "https://live.staticflickr.com/\(image.server)/\(image.id)_\(image.secret).jpg"
                        photo.pin = self.pin //DONT FORGET THIS before saving!!!!
                        
                        do {
                            try self.dataController.viewContext.save()
                        }catch{
                            fatalError("Unable to save photos: \(error.localizedDescription)")
                        }
                        
                        self.collectionView.reloadData()
                    }
                    print("album saved")
                }else{
                    fatalError("error : \(String(describing: error?.localizedDescription))")
                }
            }
        }else{
            return
        }
    }
    
  
    
    func setupFetchedResultsController(){
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin) //fetch to the photos spesific to the clicked pin.
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch couldn't be performed: \(error.localizedDescription)")
        }
    }
    
    
    func setupMap(){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate.longitude = pin.longitude
        annotation.coordinate.latitude = pin.latitude
        mapView.addAnnotation(annotation)
        
        //center the pin
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        //set zoom level
        let span = MKCoordinateSpan(latitudeDelta: 0.275, longitudeDelta: 0.275)
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setCenter(coordinate, animated: true)
        mapView.setRegion(region, animated: true)
        
    }
    
}

//extension PhotoAlbumVC :UICollectionViewDelegateFlowLayout {
//
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//
//
////        return CGSize(width: <#T##CGFloat#>, height: <#T##CGFloat#>)
//
//    }
//}
