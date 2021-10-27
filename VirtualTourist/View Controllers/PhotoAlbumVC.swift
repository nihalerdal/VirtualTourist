//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Nihal Erdal on 9/10/21.
//

import UIKit
import MapKit

class PhotoAlbumVC: UIViewController , MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var renewButton: UIButton!
    
    var annotation: MKAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        mapView.delegate = self
        mapView.addAnnotation(annotation)
        
        //center the pin
        let coordinate =  CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        mapView.setCenter(coordinate, animated: true)
        
        getPhotos()
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
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collection item number: \(DataModel.photos.count)")
        return DataModel.photos.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        let imageForCell = DataModel.photos[indexPath.row]
        
        FlickerClient.downloadPhotos(serverId: imageForCell.server, id: imageForCell.id, secret: imageForCell.secret) { data, error in
            guard let data = data else {return }
            let image = UIImage(data: data)
            cell.imageView.image = image
            print("download is done")
        }
        
        return cell
        
    }
    
    
    
    func getPhotos(){
        FlickerClient.getPhotos(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude) { response, error in
            if error == nil {
                DataModel.photos = (response?.photos.photo)!
                print("lat: \(self.annotation.coordinate.latitude), lon:\(self.annotation.coordinate.longitude)")
            }else{
                error?.localizedDescription
            }
            
        }
        
    }
    
}

