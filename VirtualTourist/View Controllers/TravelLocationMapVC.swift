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
        loadZoomLevel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.isUserInteractionEnabled = true
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTap(gesture: )))
        mapView.addGestureRecognizer(gestureRecognizer)
        saveZoomLevel()
   
    }
    
    @objc func longTap(gesture: UILongPressGestureRecognizer ){
        //as soon as  long press is ended
        if gesture.state == .ended{
            //get coordinates and create the pin
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            //add annotaion
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            mapView.setCenter(mapView.centerCoordinate, animated: true)
            
            persistPin(lat: coordinate.latitude, lon: coordinate.longitude)
            print("pin: \(coordinate.latitude), \(coordinate.longitude)")
            
        }
    }
    
    //MARK: pin view decoration - right callout accessory view
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
     
    //MARK: navigate to PhotoAlbumVC
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)  // otherwise it always shows same pin. you need to deselect
        
        let latitudeClicked = view.annotation?.coordinate.latitude
        let longitudeClicked = view.annotation?.coordinate.longitude
        
        //Find the clicked pin in Core Data.
        if let pins = fetchedResultsController.fetchedObjects{
            for pin in pins {
                if pin.latitude == latitudeClicked && pin.longitude == longitudeClicked {
                    if let vc = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumVC") as? PhotoAlbumVC {
                        vc.pin = pin
                        vc.dataController = dataController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else {
                        fatalError("error!")
                        
                    }
                }
            }
        }
    }
    
    func persistPin(lat: Double, lon: Double){
        let pin = Pin(context: dataController!.viewContext)
        pin.latitude = lat
        pin.longitude = lon
        pin.creationDate = Date()
        
        do{
            try dataController?.viewContext.save()
        }catch{
            fatalError("Unable to save data")
        }
        
        setupFetchedResultsController() //-> after saving the pin, grab pins from core data again so that it includes the new one.
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
        
    //MARK: for the first time
    func saveZoomLevel(){
        
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: KeysForZoomLevel.latitude)
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: KeysForZoomLevel.longitude)
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: KeysForZoomLevel.latitudeDelta)
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: KeysForZoomLevel.longitudeDelta)
        
    }
    
    //MARK: if it has launched before
    func loadZoomLevel(){
        
        guard let longitude = UserDefaults.standard.object(forKey: KeysForZoomLevel.longitude) as? Double else {return}
        guard let latitude = UserDefaults.standard.object(forKey: KeysForZoomLevel.latitude) as? Double else {return}
        guard let latitudeDelta = UserDefaults.standard.object(forKey: KeysForZoomLevel.latitudeDelta) as? Double else {return}
        guard let longitudeDelta = UserDefaults.standard.object(forKey: KeysForZoomLevel.longitudeDelta) as? Double else {return}
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        
        //MARK: create a pin objects
        if let pins = fetchedResultsController.fetchedObjects {
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                mapView.addAnnotation(annotation)
                
            }
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

            saveZoomLevel()
            
    }

    
}
