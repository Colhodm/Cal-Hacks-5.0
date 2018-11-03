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
    var zoomLevel: Float = 10.0
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? contractsConfirm
        {
            vc.userID = userid
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
        
        let path = GMSMutablePath()
        
        //for each point you need, add it to your path
        path.add(position)
        if locationManager.location != nil{
            path.add((locationManager.location?.coordinate)!)
            mapView?.isMyLocationEnabled = true
        }
        //Update your mapView with path
        let mapBounds = GMSCoordinateBounds(path: path)
        let cameraUpdate = GMSCameraUpdate.fit(mapBounds)
        mapView.moveCamera(cameraUpdate)
        locationManager.startUpdatingLocation()
        makeGetRequest()
        mapView.isHidden = true
    }
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: Selector("makeGetRequest"), userInfo: nil, repeats: true)
    }
    func makePostRequest(contractID: String){
        
        //create the url with URL
        var request = URLRequest(url: URL(string: "http://54.193.17.183:5000/accept_contract")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = ["contractID":contractID, "userID":userid] as Dictionary<String, String>
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        Alamofire.request(request).responseJSON { (response) in
            print(response)
        }
        
    }
    
    
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // this function makes the get request to the backend to write some information
    @objc func makeGetRequest(){
            //create the url with URL
            var request = URLRequest(url: URL(string: "http://54.193.17.183:5000/get_contracts_spatial")!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let myCoords = (locationManager.location?.coordinate)!
        let quickone = "(" + myCoords.latitude.description
        let tempone = quickone
            + "," + myCoords.longitude.description
        let sourcefinal =    tempone +  ")"
        let parameters = ["location":sourcefinal, "radius": "1"] as Dictionary<String, String>
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
            Alamofire.request(request).responseJSON { (response) in
                let temp = response.value! as? [Any]
                self.renderData(responseData: temp!)
                
            }
        }
    
    func renderData(responseData: [Any]){
        // do some parsing to get the individual coordinates
        // assuming we create some list:
        // we're basically going to iterate through list and add them all to a path
        let path = GMSMutablePath()
        // latitude: 37.8716,longitude: -122.2727
        for name in responseData {
            let myCurrent = name as? Dictionary<String,Any>
            let start_location = myCurrent!["startLocation"] as? [Double]
            let end_location = myCurrent!["endlocation"] as? [Double]
            let contract_id = myCurrent!["_id"] as? Dictionary<String,Any>
            let validity = myCurrent!["valid"]
            let price = myCurrent!["price"]
            let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(start_location![0]), longitude: CLLocationDegrees(start_location![1]))
            let marker = GMSMarker(position: position)
            marker.title = "lops"
            marker.snippet = contract_id!["$oid"] as? String
            marker.map = mapView
            path.add(CLLocationCoordinate2D(latitude: CLLocationDegrees(start_location![0]), longitude: CLLocationDegrees(start_location![1])))
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
        makePostRequest(contractID: (marker.snippet)!)
        return false
    }
    
}
