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
    var zoomLevel: Float = 2
    var timer = Timer()
    var logIn = false
    var placesClient: GMSPlacesClient!
    var userid = finaluserid
    var myArray = [String]()
    var querylen = 4
    var myPlacesSoFar = [GooglePlaces.GMSPlace]()
    var placeNames = [String : GooglePlaces.GMSPlace]()
    var finalDest: GMSPlace!
    var contractsOpen = false

    @IBOutlet weak var myBottom: UIView!
    
    @IBOutlet weak var deliver: UIButton!
    
    @IBOutlet weak var myProfile: UIButton!
    @IBOutlet weak var mySearch: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var mySearchBut: UIButton!
    @IBOutlet weak var myView: UIView!
    
    @IBOutlet weak var myContractView: UIView!
    var isMap = true
    
    //@IBOutlet weak var myStack: UIStackView!
   // @IBOutlet weak var myOptions: UITableView!
    
    
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

    
    @IBAction func myContractList(_ sender: Any) {
        if isMap{
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.mapView.alpha = 0 // Here you will get the animation you want
            self.myContractView.alpha = 1
        }, completion: { _ in
            self.mapView.isHidden = true // Here you hide it when animation done
            self.myContractView.isHidden = false
        })
            if let temp = sender as? UIButton{
                temp.setTitle("Map", for: [])
            }
            isMap = false
        } else {
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.mapView.alpha = 1 // Here you will get the animation you want
            self.myContractView.alpha = 0
        }, completion: { _ in
            self.mapView.isHidden = false // Here you hide it when animation done
            self.myContractView.isHidden = true
            if let temp = sender as? UIButton{
                temp.setTitle("List", for: []
                )
            }
            self.isMap = true
        })
        }
    }
    @IBAction func switchIcons(_ sender: Any) {
        if let temp = sender as? UIButton{
            if !contractsOpen{
                temp.setImage(UIImage(named: "icons8-map-30.png"), for: .normal)
                contractsOpen = true
            } else {
                temp.setImage(UIImage(named: "icons8-todo-list-30.png"), for: .normal)
                contractsOpen = false

            }
        }

    }
    
    @IBAction func unWindStatusHub(segue:UIStoryboardSegue) {
        
    }
    @IBAction func unWindStatusHubPart2(segue:UIStoryboardSegue) {
        
    }
    @IBAction func unWindSearch(segue:UIStoryboardSegue) {
        
    }
    @IBAction func toggleSideBar(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        if let temp = sender as? UIButton{
            // bug here when we return from the page of ordering    21q
            print("BUGGING OUT AND CAUSING It to DISSAPEAR")
            temp.isHidden = true
        }
        
    }
    
   
    override func viewDidLoad() {
        print("XXXXXX")
        print(userid)
        print("XXXXX")
        super.viewDidLoad()
        // Think about how to fix map stuff like being able to zoom in
        //mapView.addSubview(myView)
        //mapView.addSubview(myBottom)
        mySearchBut.layer.cornerRadius = 10
        mySearchBut.clipsToBounds = true
        mapView.addSubview(mySearch)
        print(mySearchBut)




        self.locationManager.delegate = self
       //self.myOptions.delegate = self
        //self.myOptions.dataSource = self
        //self.myOptions.isScrollEnabled = true;
        //self.myOptions.isHidden = true;
        self.locationManager.startUpdatingLocation()
        scheduledTimerWithTimeInterval()
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        //searchBar.delegate = self
        locationManager.delegate = self
        let path = GMSMutablePath()
        self.placesClient = GMSPlacesClient.shared()
        self.navigationController?.setNavigationBarHidden(true, animated: true)

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
        locationManager.startUpdatingLocation()
        makeGetRequest()
        for gesture in mapView.gestureRecognizers! {
            mapView.removeGestureRecognizer(gesture)
        }
        self.navigationController?.isToolbarHidden = true
        self.navigationItem.hidesBackButton = true
        self.deliver.alpha = 0.5
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        print("did i even run")
        return .lightContent
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: Selector("makeGetRequest"), userInfo: nil, repeats: true)
    }
    func makePostRequest(contractID: String){
        
        //create the url with URL
        var request = URLRequest(url: URL(string: "http://13.57.239.255:5000/accept_contract")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = ["contractID":contractID, "userID":userid] as! Dictionary<String, String>
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        Alamofire.request(request).responseJSON { (response) in
            
        }
        
    }
    
    
    
    

    @IBAction func unwindToVC1(segue:UIStoryboardSegue){
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // this function makes the get request to the backend to write some information
    @objc func makeGetRequest(){
            //create the url with URL
        var finalDest = ""
        if self.finalDest != nil{
        finalDest = self.finalDest.name
        }
            var sourcefinal2 = ""
            var request = URLRequest(url: URL(string: "http://13.57.239.255:5000/get_contracts_spatial")!)
        if finalDest != "" {
            request = URLRequest(url: URL(string: "http://13.57.239.255:5000/get_contracts_spatial_2")!)
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
}

extension MapViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        makePostRequest(contractID: (marker.snippet)!)
        return false
    }
    
}
extension MapViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchRecords(textField: searchBar.text!)
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
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let indexPath = tableView.indexPathForSelectedRow
//
//        let cell = tableView.cellForRow(at: indexPath!)! as UITableViewCell
//
//        if cell.textLabel?.text?.count == 0{
//            searchBar.text = "Sorry, no matches were found please enter a new query"
//            //myOptions.isHidden = true
//            return
//        } else {
//            searchBar.text = (cell.textLabel?.text as? String)
//            finalDest = (cell.textLabel?.text)!
//            myPlacesSoFar.append(self.placeNames[(cell.textLabel?.text)!]!)
//           // myOptions.isHidden = true
//            return
//        }
//    }
    
    
}


