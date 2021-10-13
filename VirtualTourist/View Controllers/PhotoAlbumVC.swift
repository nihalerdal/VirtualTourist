//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Nihal Erdal on 9/10/21.
//

import UIKit
import MapKit

class PhotoAlbumVC: UIViewController , MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var renewButton: UIButton!
    
    var annotation: MKAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.addAnnotation(annotation)
        
        //center the pin
        let coordinate =  CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        mapView.setCenter(coordinate, animated: true)
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
    
    
    //    func getPhotos(){
    //        FlickerClient.getPhotos(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude) { photos, error in
    //            guard let photos = photos else {return}
    //                pho
    //            }
    //
    //            }
    //        }
    //    }
    
}
 
