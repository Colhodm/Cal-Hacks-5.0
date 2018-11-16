//
//  GMaps.swift
//  Toothpick
//
//  Created by ananya mukerjee on 11/3/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.


import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire

class MapViewController: UIViewController  {
    var zoomLevel: Float = 10.0
    var timer = Timer()
    var logIn = false
    var placesClient: GMSPlacesClient!
    var userid = ""
    var myArray = [String]()
    var querylen = 4
    var myPlacesSoFar = [GooglePlaces.GMSPlace]()
    var placeNames = [String : GooglePlaces.GMSPlace]()
    var finalDest = ""

    
    @IBOutlet weak var searchBar: UITextField!
    
    
    
    @IBOutlet weak var myStack: UIStackView!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var myOptions: UITableView!
    
    
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
        if let vc = segue.destination as? LoginController
        {
            vc.userid = userid
        }
    }
    
    @IBAction func toggleSideBar(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Think about how to fix map stuff like being able to zoom in
        mapView.addSubview(myStack)

        self.locationManager.delegate = self
        self.myOptions.delegate = self
        self.myOptions.dataSource = self
        self.myOptions.isScrollEnabled = true;
        self.myOptions.isHidden = true;
        self.locationManager.startUpdatingLocation()
        scheduledTimerWithTimeInterval()
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        //searchBar.delegate = self
        locationManager.delegate = self
        let path = GMSMutablePath()
        self.placesClient = GMSPlacesClient.shared()


        let position = CLLocationCoordinate2D(latitude: 37.8716,longitude: -122.2727)
        
        
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
        for gesture in mapView.gestureRecognizers! {
            mapView.removeGestureRecognizer(gesture)
        }
        self.navigationController?.isToolbarHidden = true
        self.navigationItem.hidesBackButton = true
    }
    @objc func searchRecords(textField:String){
        placeAutocomplete()
        self.myOptions.reloadData()
        self.myOptions.isHidden = false
    }
    func filterArray(){
        var temp = [String]()
        for restaurant in myArray{
            if restaurant.contains(searchBar.text!){
                temp.append(restaurant)
            }
        }
        self.myArray = temp
        self.querylen = searchBar.text!.count
    }
    func placeAutocomplete() {
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        var temp = searchBar.text! as! String
        placesClient.autocompleteQuery(temp, bounds: nil, filter: filter, callback: {(results, error) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            if let results = results {
                // SHOULD FIX THIS SO IT MAKES LESS CALLS TO GOOGLE API SINCE WE"RE THROTTLED
                self.myArray = [String]()
                for result in results {
                    self.myArray.append(result.attributedPrimaryText.string)
                    self.placesClient.lookUpPlaceID(result.placeID!, callback: { (place, error) -> Void in
                        if let error = error {
                            print("lookup place id query error: \(error.localizedDescription)")
                            return
                        }
                        guard let place = place else {
                            print("No place details for \(result.placeID!)")
                            return
                        }
                        self.placeNames[result.attributedPrimaryText.string] = place
                    })
                }
            }
            self.myOptions.reloadData()
           self.myOptions.isHidden = false
        })
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
        var sourcefinal2 = ""
            var request = URLRequest(url: URL(string: "http://54.193.17.183:5000/get_contracts_spatial")!)
        if finalDest != "" {
            request = URLRequest(url: URL(string: "http://54.193.17.183:5000/get_contracts_spatial_2")!)
        }
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let myCoords = (locationManager.location?.coordinate)!
        let quickone = "(" + myCoords.latitude.description
        let tempone = quickone
            + "," + myCoords.longitude.description
        let sourcefinal =    tempone +  ")"
        if finalDest != "" {
        let myCoords2 = placeNames[finalDest]?.coordinate
            let quickone2 = "(" + (myCoords2?.latitude.description)!
        let tempone2 = quickone2
            + "," + (myCoords2?.longitude.description)!
          sourcefinal2 =    tempone2 +  ")"
    }
        var parameters = ["location":sourcefinal, "radius": "1"] as Dictionary<String, String>
        
        if finalDest != "" {
             parameters = ["sloc":sourcefinal, "eloc": sourcefinal2 ,"radius":"1"] as Dictionary<String, String>
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
            Alamofire.request(request).responseJSON { (response) in
                print(response)
                if response.value == nil{
                    return
                }
                let temp = response.value! as? [Any]
                if temp == nil{
                    return
                }
                self.renderData(responseData: temp!)
                
            }
        }
    
    func renderData(responseData: [Any]){
        // do some parsing to get the individual coordinates
        // assuming we create some list:
        // we're basically going to iterate through list and add them all to a path
        //let path = GMSMutablePath()
        // latitude: 37.8716,longitude: -122.2727
        for name in responseData {
            print("RUNNING")
            let myCurrent = name as? Dictionary<String,Any>
            let start_location = myCurrent!["startLocation"] as? [Double]
            let end_location = myCurrent!["endlocation"] as? [Double]
            let contract_id = myCurrent!["_id"] as? Dictionary<String,Any>
            let validity = myCurrent!["valid"]
            let price = myCurrent!["price"]
            let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(start_location![0]), longitude: CLLocationDegrees(start_location![1]))
            let marker = GMSMarker(position: position)
            marker.title = myCurrent!["title"] as! String
            marker.snippet = contract_id!["$oid"] as? String
            marker.map = mapView
            //path.add(CLLocationCoordinate2D(latitude: CLLocationDegrees(start_location![0]), longitude: CLLocationDegrees(start_location![1])))
        }
       // if locationManager.location != nil{
        //    path.add((locationManager.location?.coordinate)!)
         //   mapView?.isMyLocationEnabled = true
       // }
        
    //Update your mapView with path
    //   let mapBounds = GMSCoordinateBounds(path: path)
     //   let cameraUpdate = GMSCameraUpdate.fit(mapBounds)
      //  mapView.moveCamera(cameraUpdate)
       // locationManager.startUpdatingLocation()
    }
}




// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error){
        print(error)
        return
    }
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.first else {
//            return
//        }
//        if ((locationManager.location?.coordinate) != nil) {
//        let path = GMSMutablePath()
//        path.add((locationManager.location?.coordinate)!)
//        mapView?.isMyLocationEnabled = true
//        //Update your mapView with path
//        let mapBounds = GMSCoordinateBounds(path: path)
//        let cameraUpdate = GMSCameraUpdate.fit(mapBounds)
//        mapView.moveCamera(cameraUpdate)
//        return
//    }
    
//}
}

extension MapViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        makePostRequest(contractID: (marker.snippet)!)
        return false
    }
    
}
extension MapViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchRecords(textField: searchBar.text!)
        searchBar.resignFirstResponder()
    }
    
}

extension MapViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(myArray.count)
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("AM IN HERE")
        let temp = "myArray"
        var cell = tableView.dequeueReusableCell(withIdentifier: temp)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: temp)
        }
        // FIX ME INDEX OUT OF RANGE ERROR
        cell?.textLabel?.text = myArray[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        
        let cell = tableView.cellForRow(at: indexPath!)! as UITableViewCell
        
        if cell.textLabel?.text?.count == 0{
            searchBar.text = "Sorry, no matches were found please enter a new query"
            myOptions.isHidden = true
            return
        } else {
            searchBar.text = (cell.textLabel?.text as? String)
            finalDest = (cell.textLabel?.text)!
            myPlacesSoFar.append(self.placeNames[(cell.textLabel?.text)!]!)
            myOptions.isHidden = true
            return
        }
    }
    
    
}


