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
import SafariServices

class MapViewController: UIViewController ,SFSafariViewControllerDelegate {
    var zoomLevel: Float = 2
    var timer = Timer()
    var logIn = false
    var placesClient: GMSPlacesClient!
    var userid = finaluserid
    var myArray = [String]()
    var stateValue: String?
    var registedForStripe = false
    var mostRecentID = ""

    var querylen = 4
    var myPlacesSoFar = [GooglePlaces.GMSPlace]()
    var placeNames = [String : GooglePlaces.GMSPlace]()
    var finalDest: GMSPlace!
    var contractsOpen = false

    @IBOutlet weak var myBottom: UIView!
    
    @IBOutlet weak var myStripeDropdown: UIView!
    //@IBOutlet weak var deliver: UIButton!
    
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
            temp.isHidden = true
        }
        
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Think about how to fix map stuff like being able to zoom in
        //mapView.addSubview(myView)
        //mapView.addSubview(myBottom)
        myStripeDropdown.isHidden = true
        mySearchBut.layer.cornerRadius = 10
        mySearchBut.clipsToBounds = true
        mapView.addSubview(mySearch)
        mapView.addSubview(myStripeDropdown)




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
        mapView.center = self.view.center

        locationManager.startUpdatingLocation()
        makeGetRequest()
        for gesture in mapView.gestureRecognizers! {
            mapView.removeGestureRecognizer(gesture)
        }
        self.navigationController?.isToolbarHidden = true
        self.navigationItem.hidesBackButton = true
        //self.deliver.alpha = 0.5
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: Selector("wrapperTimed"), userInfo: nil, repeats: true)
    }
    @objc func wrapperTimed(){
        makeGetRequest()
        updateLocation()
    }
    func makePostRequest(contractID: String){
        
        //create the url with URL
        var request = URLRequest(url: URL(string: urlbase + "accept_contract")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let myCoords = (locationManager.location?.coordinate)!
        let driverLat = myCoords.latitude.description
        let driverLon = myCoords.longitude.description
        let parameters = ["contractID":contractID, "userID":finaluserid,"driverLat":driverLat,"driverLon":driverLon,"phone":personalPhone,"deliveryToken":token] as! Dictionary<String, String>
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        Alamofire.request(request).responseJSON { (response) in
            
        }
        
    }
    
    func updateLocation(){
        
        //create the url with URL
        if locationManager.location == nil{
            return
        }
        var request = URLRequest(url: URL(string: urlbase + "update_driver_position")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let myCoords = (locationManager.location?.coordinate)!
        let driverLat = myCoords.latitude.description
        let driverLon = myCoords.longitude.description
        let parameters = [ "userID":finaluserid,"driverLat":driverLat,"driverLon":driverLon] as! Dictionary<String, Any>
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        Alamofire.request(request).responseJSON { (response) in
            
        }
        
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        print(timer)
        print(locationManager.location)
    }

    @IBAction func unwindToVC1(segue:UIStoryboardSegue){
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // this function makes the get request to the backend to write some information
    func makeGetRequest(){
            //create the url with URL
        if locationManager.location == nil{
            print("EXITING DISGRACEFULLY HERE")
            return
        }
        var finalDest = ""
        if self.finalDest != nil{
        finalDest = self.finalDest.name
        }
            var sourcefinal2 = ""
            var request = URLRequest(url: URL(string: urlbase + "get_contracts_spatial")!)
        if finalDest != "" {
            request = URLRequest(url: URL(string: urlbase + "get_contracts_spatial_2")!)
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
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
        alignAccountID()
    }
    func alignAccountID(){
            //create the url with URL
            var request = URLRequest(url: URL(string: urlbase + "align_id")!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = [ "userID":finaluserid,"state":self.stateValue] as! Dictionary<String, Any>
            
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
                
            } catch let error {
                print(error.localizedDescription)
            }
            Alamofire.request(request).responseJSON { (response) in
                if response.value! == nil{
                    return
                }
                let temp = response.value! as? String
                print(temp)
                if temp == "success"{
                    // set boolean class condition we no longer need to launch safari
                    self.registedForStripe = true
                    self.makePostRequest(contractID: self.mostRecentID)
                    self.myStripeDropdown.isHidden = true
                } else {
                    return
                }
            }
    }
    
    @IBAction func confirmedDelivery(_ sender: Any) {

        print("attempting to confirm your status the courier")
        // need to add logic so that you dont have to register everytime
        if !methodOfPayment{
        let serverendpoint = urlbase + "payment_establishment"
        let stateValue = String(arc4random())
        self.stateValue = stateValue
        let myLink = computeURL(string: "https://connect.stripe.com/express/oauth/authorize?redirect_uri=\(serverendpoint)&client_id=\(clientID!)&state={\(stateValue)}")
        print(serverendpoint)
        if myLink.absoluteString.count > 5{
        let controller = SFSafariViewController(url: myLink)
        self.present(controller, animated: true, completion: nil)
        controller.delegate = self
        print("finished opening this up")
            }
        } else {
            self.makePostRequest(contractID: self.mostRecentID)
            self.myStripeDropdown.isHidden = true

        }
    }
    func computeURL(string: String) -> URL {
        let testurlStr = string
        let components = transformURLString(testurlStr)
        print(components)
        if let url = components?.url {
            return url
        } else {
            return URL(string:"")!
        }
        return URL(string:"")!
    }
    
    func transformURLString(_ string: String) -> URLComponents? {
        guard let urlPath = string.components(separatedBy: "?").first else {
            return nil
        }
        var components = URLComponents(string: urlPath)
        if let queryString = string.components(separatedBy: "?").last {
            components?.queryItems = []
            let queryItems = queryString.components(separatedBy: "&")
            for queryItem in queryItems {
                guard let itemName = queryItem.components(separatedBy: "=").first,
                    let itemValue = queryItem.components(separatedBy: "=").last else {
                        continue
                }
                components?.queryItems?.append(URLQueryItem(name: itemName, value: itemValue))
            }
        }
        return components!
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
        myStripeDropdown.isHidden = false
        self.mostRecentID = (marker.snippet)!
        // will add in the logic to determine this

        return true
    }
    /* set a custom Info Window */
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 100))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6
        
        let lbl1 = UILabel(frame: CGRect.init(x: 8, y: 8, width: view.frame.size.width - 16, height: 15))
        lbl1.text = marker.title
        view.addSubview(lbl1)
        
        let lbl2 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + 3, width: view.frame.size.width - 16, height: 15))
        lbl2.text = "This delivery has some metadata"
        lbl2.font = UIFont.systemFont(ofSize: 14, weight: .light)
        view.addSubview(lbl2)
        
        return view
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
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let temp = "myArray"
        var cell = tableView.dequeueReusableCell(withIdentifier: temp)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: temp)
        }
        // FIX ME INDEX OUT OF RANGE ERROR
        cell?.textLabel?.text = myArray[indexPath.row]
        return cell!
    }
    
    
}


