//
//  TravelLocationMapVC.swift
//  VirtualTourist
//
//  Created by Nihal Erdal on 9/10/21.
//

import UIKit
import MapKit
import CoreData


class TravelLocationMapVC: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController : DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.isUserInteractionEnabled = true
        
        
        setupFetchedResultsController()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.isUserInteractionEnabled = true
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTap(gesture: )))
        mapView.addGestureRecognizer(gestureRecognizer)
   
    }
    
    @objc func longTap(gesture: UILongPressGestureRecognizer ){
        //as soon as  long press is ended
        if gesture.state == .ended{
            //get coordinates and create the pin
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            persistPin(lat: coordinate.latitude, lon: coordinate.longitude)
            
        }
    }
    
    //pin view decoration - right callout accessory view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if  pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .red
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    //navigate to PhotoAlbumVC
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        if let vc = storyboard?.instantiateViewController(identifier: "PhotoAlbumVC") as? PhotoAlbumVC {
            vc.annotation = view.annotation
            vc.dataController = dataController
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func persistPin(lat: Double, lon: Double){
        let pin = Pin(context: dataController!.viewContext)
        pin.latitude = lat
        pin.longitude = lon
        pin.creationDate = Date()
        
        try? dataController?.viewContext.save()
    }
    
    fileprivate func setupFetchedResultsController() {
        //creat fetchRequest
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
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
