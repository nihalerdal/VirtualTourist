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
    var photo: Photo!
    var pin: Pin!
    
    var annotation: MKAnnotation!
    
    var dataController : DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.delegate = self
        mapView.addAnnotation(annotation)
        renewButton.isEnabled = false
        
        
        //center the pin
        let coordinate =  CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        mapView.setCenter(coordinate, animated: true)
        
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPhotos()
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
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let  aPhoto = fetchedResultsController.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        FlickerClient.downloadPhotos(imageURL: URL(string: (aPhoto.url)!)!) { data, error in
                
                if error == nil {
                guard let data = data else {return}
                let image = UIImage(data: data)
                cell.imageView.image = image
                    try? self.dataController.viewContext.save()
                }else{
                    fatalError("error:\(error?.localizedDescription)")
                }
            }
        
        return cell
        
    }
    
    
    
    func getPhotos(){
        
        if fetchedResultsController.fetchedObjects?.count == 0{
            FlickerClient.getPhotos(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude) { response, error in
                if error == nil {
                    guard let response = response else {return}
                    for image in response.photos.photo{
                        let photo = Photo(context: self.dataController.viewContext)
                        photo.creationDate = Date()
                        photo.url = "https://live.staticflickr.com/\(image.server)/\(image.id)_\(image.secret).jpg"
                        try? self.dataController.viewContext.save()
                    }
                    print("album saved")
                }else{
                    fatalError("error : \(String(describing: error?.localizedDescription))")
                }
            }
        }else{
            renewButton.isEnabled = true
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
    
}

