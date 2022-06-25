//
//  MapVC.swift
//  FoursquareClone
//
//  Created by Unsal Oner on 7.03.2022.
//

import UIKit
import MapKit
import Parse

class MapVC: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(saveButtonClicked))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backButtonClicked))
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer){
        
        if gestureRecognizer.state == .began{
            
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let touchedCoordinats = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
        
            PlaceModel.sharedInstance.placeLatitude = String(touchedCoordinats.latitude)
            PlaceModel.sharedInstance.placeLongitude = String(touchedCoordinats.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinats
            annotation.title = PlaceModel.sharedInstance.placeName
            annotation.subtitle = PlaceModel.sharedInstance.placeType
            
            self.mapView.addAnnotation(annotation)
            
        
        }
     }
    func  locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //        locationManager.stopUpdatingLocation()
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }

        @objc func saveButtonClicked(){
//        PARSE
            let placeModel = PlaceModel.sharedInstance
            let object = PFObject(className: "Places")
            object["name"] = placeModel.placeName
            object["type"] = placeModel.placeType
            object["atmosphere"] = placeModel.placeAtmosphere
            object["latitude"] = placeModel.placeLatitude
            object["longitude"] = placeModel.placeLongitude
    
            if let imageData = placeModel.placeImage.jpegData(compressionQuality: 0.5){
                object["image"] = PFFileObject(name: "image.jpg", data: imageData)
            }
            object.saveInBackground { success, error in
                if error != nil {
                    let alert = UIAlertController(title: "Error!", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }else{
                    self.performSegue(withIdentifier: "fromMapVCtoPlacesVC", sender: nil)
                }
            }
        }
   
    @objc func backButtonClicked() {
        
        self.dismiss(animated: true, completion: nil)
    }

}
