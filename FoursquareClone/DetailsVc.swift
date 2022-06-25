//
//  DetailsVc.swift
//  FoursquareClone
//
//  Created by Unsal Oner on 7.03.2022.
//

import UIKit
import MapKit
import Parse

class DetailsVc: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var detailsImage: UIImageView!
    
    @IBOutlet weak var detailsName: UILabel!
    
    @IBOutlet weak var detailsType: UILabel!
    @IBOutlet weak var detailsAtmosphere: UILabel!
    @IBOutlet weak var detailsMap: MKMapView!
    
    var chosenPlaceId = ""
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromParse()
        detailsMap.delegate = self
}
    func getDataFromParse() {
        let query = PFQuery(className: "Places")
                query.whereKey("objectId", equalTo: chosenPlaceId)
                query.findObjectsInBackground { objects, error in
                    if error != nil {
                        
                    }else {
                        
                        if objects != nil {
                            
                           let  chosenPlaceObject = objects![0]
//                          OBJECTS
                            if let placeName = chosenPlaceObject.object(forKey: "name") as? String {
                                self.detailsName.text = placeName
                            }
                            if let placeAtmosphere = chosenPlaceObject.object(forKey: "atmosphere") as? String {
                                self.detailsAtmosphere.text = placeAtmosphere
                            }
                            if let placeType = chosenPlaceObject.object(forKey: "type") as? String {
                                self.detailsType.text = placeType
                         }
                            if let  placeLatitude = chosenPlaceObject.object(forKey: "latitude") as? String {
                                if let placeLatitudeDouble = Double(placeLatitude){
                                    self.chosenLatitude = placeLatitudeDouble
                                }
                            }
                            if let  placeLongitude = chosenPlaceObject.object(forKey: "longitude") as? String {
                                if let placeLongitudeDouble = Double(placeLongitude){
                                    self.chosenLongitude = placeLongitudeDouble
                                }
                    }
                            if let imageData = chosenPlaceObject.object(forKey: "image") as? PFFileObject {
        //                        Datayı download ediyor.
                                imageData.getDataInBackground { data, error in
                                    if error == nil {
                                        self.detailsImage.image = UIImage(data: data!)
                                    }
                                }
                            }
                        }
//                        MAPS
                        let location = CLLocationCoordinate2D(latitude: self.chosenLatitude, longitude: self.chosenLongitude)
                        let span = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
                        let region = MKCoordinateRegion(center: location, span: span)
                        
                        self.detailsMap.setRegion(region, animated: true)
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location
                        annotation.title = self.detailsName.text!
                        annotation.subtitle = self.detailsType.text!
                        self.detailsMap.addAnnotation(annotation)
                        
                    }
                }
            }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
        return nil
        }
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.blue
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if self.chosenLatitude != 0.0 && self.chosenLongitude != 0.0 {
            let requestLocation = CLLocation(latitude: self.chosenLatitude, longitude: self.chosenLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
                if let placemark = placemarks {
                    if placemark.count > 0{
                        let mkPlacemark = MKPlacemark(placemark: placemark[0])
//                       navigasyonu açmak için
                        let mapItem = MKMapItem(placemark: mkPlacemark)
                        mapItem.name = self.detailsName.text!
//                        Navigasyon açıldığında arabayla nasıl gidildiğini gösterir ilk olarak.
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        mapItem.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        }
            
    }
    }
