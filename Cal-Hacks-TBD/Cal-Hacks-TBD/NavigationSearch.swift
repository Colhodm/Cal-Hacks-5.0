//
//  NavigationSearch.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 12/19/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.
//

import UIKit
import Alamofire
import GooglePlaces

class NavigationSearch: UIViewController {
    var locationManager = CLLocationManager()
    @IBOutlet weak var Start_Loc: UITextField!
    @IBOutlet weak var Destination: UITextField!
    var placesClient: GMSPlacesClient!
    var userid = ""
    var myArray = [String]()
    var querylen = 4
    var myPlacesSoFar = [GooglePlaces.GMSPlace]()
    var placeNames = [String : GooglePlaces.GMSPlace]()
    var finalDest = ""
    var logIn = false
    
    @IBOutlet weak var myOptions: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.myOptions.delegate = self
        self.myOptions.dataSource = self
        self.myOptions.isScrollEnabled = true;
        self.myOptions.isHidden = true;
        self.placesClient = GMSPlacesClient.shared()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        Destination.addTarget(self, action: #selector(searchRecords(textField:)), for: .editingChanged)

        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? MapViewController
        {
            if finalDest != ""{
            vc.finalDest = placeNames[finalDest]!
            }
        }
    }
    @objc func searchRecords(textField:UITextField){
        if Destination.text!.count >= 4 {
            if Destination.text!.count == 4{
                placeAutocomplete()
            }
            if self.querylen <= Destination.text!.count{
                filterArray()
            } else {
                print("does this every run")
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
            if restaurant.contains(Destination.text!){
                temp.append(restaurant)
            }
        }
        self.myArray = temp
        self.querylen = Destination.text!.count
    }
    func placeAutocomplete() {
        let filter = GMSAutocompleteFilter()
        filter.type = .establishment
        placesClient.autocompleteQuery(Destination.text!, bounds: nil, filter: filter, callback: {(results, error) -> Void in
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
    
    
    
    @IBAction func switchLocText(_ sender: Any) {
        let temp = sender as! UITextField
        temp.text = "Start Location"
    }
    

}

extension NavigationSearch: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    }
}

extension NavigationSearch: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("creating entries in the table")
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
            Destination.text = "Sorry, no matches were found please enter a new query"
            myOptions.isHidden = true
            return
        } else {
            Destination.text = cell.textLabel?.text
            finalDest = Destination.text!
            myPlacesSoFar.append(self.placeNames[(cell.textLabel?.text)!]!)
            myOptions.isHidden = true
            print("performing a segue!")
            performSegue(withIdentifier: "backToMap", sender: self)
            return
        }
    }
    
    
}
