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
import Alamofire

class MapViewController: UIViewController  {
    var currentLocation: CLLocation?
    var userid = ""
    var zoomLevel: Float = 15.0
    var timer = Timer()
    var logIn = false
    

    
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
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: Selector("makeGetRequest"), userInfo: nil, repeats: true)
        print("RUNNING")
    }

    
    // this function makes the Post request to the backend to write some information
    func makePostRequest(){
        
        //create the url with URL
        var request = URLRequest(url: URL(string: "http://54.193.17.183:5000/create_account")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = ["name":"poop", "password": "tits","screenid":"poops","rating":"5"] as Dictionary<String, String>


        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        Alamofire.request(request).responseJSON { (response) in
        print(response)
        }
        
    }
    func makeUserPostRequest(){
        
        //create the url with URL
        var request = URLRequest(url: URL(string: "http://54.193.17.183:5000/new_user_info")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = ["name":"poop", "password": "tits","screenid":"poops","rating":"5"] as Dictionary<String, String>
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        Alamofire.request(request).responseJSON { (response) in
            print(response)
        }
        
    }

    
    
    // this function makes the get request to the backend to write some information
    @objc func makeGetRequest(){
            //create the url with URL
        print("RUUNNING")
            var request = URLRequest(url: URL(string: "http://54.193.17.183:5000/get_contracts_spatial")!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let myCoords = (locationManager.location?.coordinate)!
        let quickone = "(" + myCoords.latitude.description
        let tempone = quickone
            + "," + myCoords.latitude.description
        let sourcefinal =    tempone +  ")"
        print(sourcefinal)
        let parameters = ["location":"temp", "radius": "5"] as Dictionary<String, String>
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
            print("EVEN GETTING HERE")
            Alamofire.request(request).responseJSON { (response) in
                var temp = response.value!
                print(temp)
                self.renderData(responseData: response.description)
                
            }
        }
    
    func renderData(responseData: String){
        // do some parsing to get the individual coordinates
        // assuming we create some list:
        // we're basically going to iterate through list and add them all to a path
        let path = GMSMutablePath()
        // latitude: 37.8716,longitude: -122.2727
        let names = [(37.9716,-122.2727), (37.6716,-122.2727), (37.7716,-122.2727)]
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
