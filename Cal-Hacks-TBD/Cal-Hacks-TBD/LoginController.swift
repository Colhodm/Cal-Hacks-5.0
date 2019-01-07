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

class LoginController: UIViewController, UITextFieldDelegate ,STPPaymentContextDelegate {
    let stripePublishableKey = STPPaymentConfiguration.shared().publishableKey
    
    let backendBaseURL = urlbase
    
    // 3) Optionally, to enable Apple Pay, follow the instructions at https://stripe.com/docs/mobile/apple-pay
    // to create an Apple Merchant ID. Replace nil on the line below with it (it looks like merchant.com.yourappname).
    let appleMerchantID: String? = nil
    
    // These values will be shown to the user when they purchase with Apple Pay.
    let companyName = "Emoji Apparel"
    let paymentCurrency = "usd"
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    var paymentInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.paymentInProgress {
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.alpha = 1
                    //self.buyButton.alpha = 0
                }
                else {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.alpha = 0
                    //self.buyButton.alpha = 1
                }
            }, completion: nil)
        }
    }
    
    var paymentContext: STPPaymentContext?
    
    

    
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
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // Need to assign to _ because optional binding loses @discardableResult value
            // https://bugs.swift.org/browse/SR-1681
            _ = self.navigationController?.popViewController(animated: true)
        })
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.paymentContext?.retryLoading()
        })
        alertController.addAction(cancel)
        alertController.addAction(retry)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        print("SOMETHING CHANGED")
        //        self.paymentRow.loading = paymentContext.loading
        //        if let paymentMethod = paymentContext.selectedPaymentMethod {
        //            self.paymentRow.detail = paymentMethod.label
        //        }
        //        else {
        //            self.paymentRow.detail = "Select Payment"
        //        }
        //        if let shippingMethod = paymentContext.selectedShippingMethod {
        //            self.shippingRow.detail = shippingMethod.label
        //        }
        //        else {
        //            self.shippingRow.detail = "Enter \(self.shippingString) Info"
        //        }
        //        self.totalRow.detail = self.numberFormatter.string(from: NSNumber(value: Float(self.paymentContext.paymentAmount)/100))!
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        print("just requested my backend")
        MyAPIClient.sharedClient.completeCharge(paymentResult,
                                                amount: self.paymentContext?.paymentAmount ?? 5,
                                                shippingAddress: self.paymentContext?.shippingAddress,
                                                shippingMethod: self.paymentContext?.selectedShippingMethod,
                                                completion: completion)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        self.paymentInProgress = false
        let title: String
        let message: String
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            title = "Success"
            message = "You ordered a \(self.myTitle.text!) with a description of \(self.descriptionOfQuery.text!) for a price of \(self.price.text!) from \(self.finalDest)!"
        case .userCancellation:
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
   
    @IBAction func sendReq(_ sender: Any) {
        print(sender)
        if !methodOfPayment{
        paymentContext?.presentPaymentMethodsViewController()
        let temp = sender as! UIButton
        temp.setTitle("Finish", for: .normal)
        temp.titleLabel?.font.withSize(15)

        methodOfPayment = true
        } else{
            paymentContext?.requestPayment()
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
        MyAPIClient.sharedClient.baseURLString = self.backendBaseURL
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
        MyAPIClient.sharedClient.baseURLString = self.backendBaseURL
        let config = STPPaymentConfiguration.shared()
        config.publishableKey = self.stripePublishableKey
        config.appleMerchantIdentifier = self.appleMerchantID
        config.companyName = self.companyName
        
        // Create card sources instead of card tokens
        config.createCardSources = false;

        let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
        let paymentContext = STPPaymentContext(customerContext: customerContext)
        let userInformation = STPUserInformation()
        paymentContext.prefilledInformation = userInformation
        paymentContext.paymentAmount = Int(self.price.text ?? "0") ?? 0
        paymentContext.paymentCurrency = self.paymentCurrency
        self.paymentContext = paymentContext
        self.paymentContext?.hostViewController = self
        self.paymentContext?.delegate = self




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

