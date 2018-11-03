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
    var timer = Timer()

    
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
        print("IN HERE")
        // Think about how to fix map stuff like being able to zoom in
        scheduledTimerWithTimeInterval()
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        locationManager.delegate = self
        let position = CLLocationCoordinate2D(latitude: 37.8716,longitude: -122.2727)
        let marker = GMSMarker(position: position)
        marker.title = "Random"
        marker.map = mapView
        //Create a path
        let path = GMSMutablePath()
        
        //for each point you need, add it to your path
        path.add(position)
        print(locationManager.location)
        print("RANDOM")
        print(position)
        if locationManager.location != nil{
            path.add((locationManager.location?.coordinate)!)
            mapView?.isMyLocationEnabled = true
        }
        //Update your mapView with path
        let mapBounds = GMSCoordinateBounds(path: path)
        print(mapBounds)
        let cameraUpdate = GMSCameraUpdate.fit(mapBounds)
        print(cameraUpdate)
        mapView.moveCamera(cameraUpdate)
        locationManager.startUpdatingLocation()        
    }
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: Selector("makeGetRequest"), userInfo: nil, repeats: true)
    }

    
    // this function makes the Post request to the backend to write some information
    func makePostRequest(){
        let url = URL(string: "http://54.193.17.183:5000/api/get_messages")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "id=13&name=Jack"
        print("JUST BEFORE I MADE REQUEST")
        request.httpBody = postString.data(using: .utf8)
        print("MADE SOME REQUEST")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            print("WITHIN A WEIRD BLOCK")
        }
        print(task)
        print("RETURNED")

    }
    
    
    // this function makes the get request to the backend to write some information
    @objc func makeGetRequest(){
        let url = URL(string: "http://")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let postString = "id=13&name=Jack"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            self.renderData(responseData: responseString!)
        }
    }
    
    func renderData(responseData: String){
        // do some parsing to get the individual coordinates
        // assuming we create some list:
        // we're basically going to iterate through list and add them all to a path
        let path = GMSMutablePath()
        // latitude: 37.8716,longitude: -122.2727
        let names = [(12,13), (14,15), (16,17)]
        for name in names {
            path.add(CLLocationCoordinate2D(latitude: CLLocationDegrees(name.0), longitude: CLLocationDegrees(name.1)))
        }
        if locationManager.location != nil{
            path.add((locationManager.location?.coordinate)!)
            mapView?.isMyLocationEnabled = true
        }
    //Update your mapView with path
       let mapBounds = GMSCoordinateBounds(path: path)
        let cameraUpdate = GMSCameraUpdate.fit(mapBounds)
        mapView.moveCamera(cameraUpdate)
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
        37.8716
        let position = CLLocationCoordinate2D(latitude: 37.8716,longitude: -122.2727)
        //for each point you need, add it to your path
        path.add(position)
        path.add((locationManager.location?.coordinate)!)
        mapView?.isMyLocationEnabled = true
        //Update your mapView with path
        let mapBounds = GMSCoordinateBounds(path: path)
        let cameraUpdate = GMSCameraUpdate.fit(mapBounds)
        mapView.moveCamera(cameraUpdate)
        return
    }
    
}

extension MapViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("I TAPPED MARKER")
        makePostRequest()
        print("I FINISHED POSTING SHIT")
        return false
    }
    
}
