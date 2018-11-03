//
//  GMaps.swift
//  Toothpick
//
//  Created by ananya mukerjee on 9/19/18.
//  Copyright © 2018 Cheney. All rights reserved.
//


import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController  {
    var currentLocation: CLLocation?
    var zoomLevel: Float = 15.0
    @IBOutlet weak var mapView: GMSMapView!
    
    var locationManager = CLLocationManager()
    var selectedPlace: GooglePlaces.GMSPlace?
    
    @objc func pressButton(_ button: UIButton) {
        let destinationid = selectedPlace?.placeID
        let destinationaddy = selectedPlace?.formattedAddress
        let myfinal = """
            https://www.google.com/maps/dir/?api=1&
            """
        let temp = "destination_place_id=" + destinationid! + "&"
        let another  =  "destination=" + destinationaddy!
        let final = (myfinal+temp+another).replacingOccurrences(of: " ", with: "+")
        let finalfinal = final.replacingOccurrences(of: ",", with: "%2C")
        if (UIApplication.shared.canOpenURL(URL(string:finalfinal)!)) {
            print(finalfinal)
            UIApplication.shared.openURL(URL(string:
                finalfinal)!)
        } else {
            print("Can't use comgooglemaps://");
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Think about how to fix map stuff like being able to zoom in
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        let position = selectedPlace?.coordinate
        let marker = GMSMarker(position: position!)
        marker.title = selectedPlace?.name
        marker.map = mapView
        //Create a path
        let path = GMSMutablePath()
        
        //for each point you need, add it to your path
        path.add(position!)
        print(locationManager.location)
        if locationManager.location != nil{
            path.add((locationManager.location?.coordinate)!)
            mapView?.isMyLocationEnabled = true
        }
        //Update your mapView with path
        let mapBounds = GMSCoordinateBounds(path: path)
        let cameraUpdate = GMSCameraUpdate.fit(mapBounds)
        mapView.moveCamera(cameraUpdate)
        locationManager.startUpdatingLocation()        
        
    }
}




// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error){
        print("I FAILED")
        print(error)
        return
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        let path = GMSMutablePath()
        let position = selectedPlace?.coordinate
        //for each point you need, add it to your path
        path.add(position!)
        path.add((locationManager.location?.coordinate)!)
        mapView?.isMyLocationEnabled = true
        //Update your mapView with path
        let mapBounds = GMSCoordinateBounds(path: path)
        let cameraUpdate = GMSCameraUpdate.fit(mapBounds)
        mapView.moveCamera(cameraUpdate)
        return
    }
    
}
