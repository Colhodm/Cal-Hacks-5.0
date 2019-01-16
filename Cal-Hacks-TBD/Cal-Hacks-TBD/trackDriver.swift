//
//  trackDriver.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 1/7/19.
//  Copyright © 2019 Cal-Hacks-5.0. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
class trackDriver: UIViewController {
    var contractid: String?
    var driverLocation: CLLocationCoordinate2D?
    var locationManager = CLLocationManager()
    var timer = Timer()
    var myPhone: String?
    @IBOutlet weak var myDriversPhone: UILabel!
    @IBOutlet weak var myBack: UIButton!
    

    @IBOutlet weak var mapView: GMSMapView!
    override func viewDidLoad() {
        scheduledTimerWithTimeInterval()
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        let path = GMSMutablePath()
        myDriversPhone.text = myPhone
        let position = CLLocationCoordinate2D(latitude: 37.8716,longitude: -122.2727)
        
        
        //for each point you need, add it to your path
        if locationManager.location != nil{
            path.add((locationManager.location?.coordinate)!)
            mapView?.isMyLocationEnabled = true
        } else {
            path.add(position)
        }
        //Update your mapView with path
        let mapBounds = GMSCoordinateBounds(path: path)
        let cameraUpdate = GMSCameraUpdate.fit(mapBounds)
        
        
        
        mapView.moveCamera(cameraUpdate)
        mapView.moveCamera(GMSCameraUpdate.zoom(to: 16))
        mapView.center = self.view.center
        
        // Do any additional setup after loading the view.
    }
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(trackDriver.retrieveDriverLoc), userInfo: nil, repeats: true)
    }
    @objc func retrieveDriverLoc(){
        driverLocPost()
    }
    
    @IBAction func Confirmation(_ sender: Any) {
        // This function runs the confirmation for the process
        // of the contract
            //create the url with URL
            var request = URLRequest(url: URL(string: urlbase + "complete_contract")!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = ["userID": finaluserid,"contractID":contractid] as! Dictionary<String, String>
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                
            } catch let error {
                print(error.localizedDescription)
            }
            Alamofire.request(request).responseJSON { (response) in
                if response.value == nil{
                    return
                }
                let temp = response.value! as? Dictionary<String,Any>
                if temp == nil{
                    return
                }
                let anothertemp = temp!["success"] as? Int
                if anothertemp == 0{
                    print("oops waiting on the other person")
                }
                else if (anothertemp == 1){
                    print("WOO we're done!")
                }
                else{
                    print("Uh oh this did not seem to work")
                }
                print(anothertemp)
        }
        
    }
    
    func driverLocPost(){
            //create the url with URL
            var request = URLRequest(url: URL(string: urlbase + "fetch_driver_position")!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let parameters = ["contractID":contractid!, "userID":finaluserid] as! Dictionary<String, String>
        
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                
            } catch let error {
                print(error.localizedDescription)
            }
            Alamofire.request(request).responseJSON { (response) in
                let myCurrent = response.value as? Dictionary<String,Any>
                let driver_lat = Double(myCurrent!["driverLat"] as! String)
                let driver_lon = Double(myCurrent!["driverLon"] as! String)
                let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(driver_lat! + 0.0002), longitude: CLLocationDegrees(driver_lon!))
                self.driverLocation = position
                let marker = GMSMarker(position: position)
                marker.title = "Courier"
                marker.map = self.mapView
                // Add some code to fix the map position
            }
            
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension trackDriver: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error){
        print(error)
        return
    }
}
extension trackDriver: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //makePostRequest(contractID: (marker.snippet)!)
        return false
}
}
