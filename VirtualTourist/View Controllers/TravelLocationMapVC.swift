//
//  TravelLocationMapVC.swift
//  VirtualTourist
//
//  Created by Nihal Erdal on 9/10/21.
//

import UIKit
import MapKit


class TravelLocationMapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var dataController : DataController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.isUserInteractionEnabled = true
        
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
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
