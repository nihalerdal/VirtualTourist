//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Nihal Erdal on 9/10/21.
//

import UIKit
import MapKit

class PhotoAlbumVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var renewButton: UIButton!
    
    var annotation: MKAnnotation!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
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
