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
import Stripe
var methodOfPayment = false

class LoginController: UIViewController, UITextFieldDelegate ,STPAddCardViewControllerDelegate,STPPaymentMethodsViewControllerDelegate {
    func paymentMethodsViewController(_ paymentMethodsViewController: STPPaymentMethodsViewController, didFailToLoadWithError error: Error) {
        dismiss(animated: true, completion: nil)

    }
    
    func paymentMethodsViewControllerDidFinish(_ paymentMethodsViewController: STPPaymentMethodsViewController) {
                paymentMethodsViewController.navigationController?.popViewController(animated: true)

    }
    
    func paymentMethodsViewControllerDidCancel(_ paymentMethodsViewController: STPPaymentMethodsViewController) {
                dismiss(animated: true, completion: nil)
    }
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        dismiss(animated: true, completion: nil)
    }
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        // TODO FIGURE OUT HOW TO MAKE THIS SEGUE ONCE YOU SUCCESFULLY ADD A PAYMENT METHOD
        methodOfPayment = true
        print("DOING SOME STUFF")
        dismiss(animated: true, completion: nil)
        sendSubmitRequest()
        performSegue(withIdentifier: "status", sender: self)
        

    }
    var locationManager = CLLocationManager()
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var destination: UITextField!
    var placesClient: GMSPlacesClient!
    var userid = finaluserid
    var myArray = [String]()
    var querylen = 4
    var myPlacesSoFar = [GooglePlaces.GMSPlace]()
    var placeNames = [String : GooglePlaces.GMSPlace]()
    var finalDest = ""
    var logIn = false
    @IBOutlet weak var order: UIButton!
    

    
    
    @IBOutlet weak var myTitle: UITextField!
    @IBOutlet weak var descriptionOfQuery: UITextField!
    @IBOutlet weak var myOptions: UITableView!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
   
    @IBAction func sendReq(_ sender: Any) {
        methodOfPayment = true
        if !methodOfPayment{
            // Setup add card view controller
            let addCardViewController = STPAddCardViewController()
            addCardViewController.delegate = self
            
            // Present add card view controller
            let navigationController = UINavigationController(rootViewController: addCardViewController)
            present(navigationController, animated: true)
        }
        if methodOfPayment{
            let config = STPPaymentConfiguration()
            config.additionalPaymentMethods = .all
            config.requiredBillingAddressFields = .none
            config.appleMerchantIdentifier = "dummy-merchant-id"
            let customerContext = STPCustomerContext()

            let viewController = STPPaymentMethodsViewController(configuration: config,
                                                                 theme: .default(),
                                                                 customerContext: customerContext,
                                                                 delegate: self)
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.navigationBar.stp_theme = .default()
            present(navigationController, animated: true, completion: nil)
        }
    }
    
    func sendSubmitRequest(){
            //create the url with URL
            var request = URLRequest(url: URL(string: urlbase + "new_contract_info")!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let quick = "(" + (placeNames[finalDest]?.coordinate.latitude.description)!
        let temp = quick
            + "," + (placeNames[finalDest]?.coordinate.longitude.description)!
        let final =    temp +  ")"
        
        let myCoords = (locationManager.location?.coordinate)!
        let quickone = "(" + myCoords.latitude.description
        let tempone = quickone
            + "," + myCoords.longitude.description
        let sourcefinal =    tempone +  ")"
        let parameters = ["destination":final, "price": price.text!,"userid":userid!,"source":sourcefinal,"description":descriptionOfQuery.text!,"title":myTitle.text!] as! Dictionary<String, String>
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
            Alamofire.request(request).responseJSON { (response) in
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
        self.order.alpha = 0.5

        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func unWindMap(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToMap", sender: self)

    }
    
    @IBAction func unWindStatusHub(segue:UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? MapViewController
        {
            vc.userid = userid
           
        }
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

