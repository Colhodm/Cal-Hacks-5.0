//
//  ViewController.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 11/2/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.
//

import UIKit
import Alamofire
import GooglePlaces
class LoginController: UIViewController, UITextFieldDelegate {
    var locationManager = CLLocationManager()
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var destination: UITextField!
    var placesClient: GMSPlacesClient!
    var userid = ""
    var myArray = [String]()
    var querylen = 4
    var myPlacesSoFar = [GooglePlaces.GMSPlace]()
    var placeNames = [String : GooglePlaces.GMSPlace]()
    var finalDest = ""
    var logIn = false

    
    
    @IBOutlet weak var descriptionOfQuery: UITextField!
    @IBOutlet weak var myOptions: UITableView!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
   
    @IBAction func sendContractReq(_ sender: Any) {
        print("RUNNING THIS FUNCTION")
        sendSubmitRequest()
    }
    func sendSubmitRequest(){
            //create the url with URL
            var request = URLRequest(url: URL(string: "http://54.193.17.183:5000/new_contract_info")!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print("HERE")
        //if !destination.endEditing(false){
         //   print("EXITING HERE")
          //  return
       // }
        //let quick = "(" + (placeNames[finalDest]?.coordinate.latitude.description)!
       // let temp = quick
        //    + "," + (placeNames[finalDest]?.coordinate.longitude.description)!
        //let final =    temp +  ")"
        
        let myCoords = (locationManager.location?.coordinate)!
        let quickone = "(" + myCoords.latitude.description
        let tempone = quickone
            + "," + myCoords.latitude.description
        let sourcefinal =    tempone +  ")"
        print("XXXXXX")
        print(sourcefinal)
        print("XXXXXX")
        let parameters = ["destination":"(20,10)", "price": price.text,"userid":userid,"source":sourcefinal,"description":descriptionOfQuery.text!] as! Dictionary<String, Any>
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
            Alamofire.request(request).responseJSON { (response) in
                print(response)
                if response.description == "You were right!"{
                    //self.userid = Int(response.description)!
                    self.performSegue(withIdentifier: "victory", sender: self)
                }
                // have it flash notification that ur atempt was not correct
            }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        price.delegate = self
        destination.delegate = self
        self.locationManager.delegate = self
        self.myOptions.delegate = self
        self.myOptions.dataSource = self
        self.myOptions.isScrollEnabled = true;
        self.myOptions.isHidden = true;
        self.placesClient = GMSPlacesClient.shared()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        destination.addTarget(self, action: #selector(searchRecords(textField:)), for: .editingChanged)

        // Do any additional setup after loading the view, typically from a nib.
    }
    @objc func searchRecords(textField:UITextField){
        if destination.text!.count >= 4 {
            if destination.text!.count == 4{
                placeAutocomplete()
            }
            if self.querylen <= destination.text!.count{
                filterArray()
            } else {
            
                placeAutocomplete()
                
            }
            self.myOptions.reloadData()
            myOptions.isHidden = false;
        } else {
            myOptions.isHidden = true;
        }
        
    }
    func filterArray(){
        var temp = [String]()
        for restaurant in myArray{
            if restaurant.contains(destination.text!){
                temp.append(restaurant)
            }
        }
        self.myArray = temp
        self.querylen = destination.text!.count
    }
    func placeAutocomplete() {
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        placesClient.autocompleteQuery(destination.text!, bounds: nil, filter: filter, callback: {(results, error) -> Void in
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
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? MapViewController
        {
            vc.userid = userid
           
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension LoginController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    }
}

extension LoginController: UITableViewDelegate,UITableViewDataSource {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        
        let cell = tableView.cellForRow(at: indexPath!)! as UITableViewCell
        
        if cell.textLabel?.text?.count == 0{
            destination.text = "Sorry, no matches were found please enter a new query"
            myOptions.isHidden = true
            return
        } else {
            destination.text = cell.textLabel?.text
            finalDest = destination.text!
            myPlacesSoFar.append(self.placeNames[(cell.textLabel?.text)!]!)
            myOptions.isHidden = true
            return
        }
    }
    
    
}

