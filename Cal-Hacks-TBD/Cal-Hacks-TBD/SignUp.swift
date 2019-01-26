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
class SignUp: UIViewController, UITextFieldDelegate {
    
    var locationManager = CLLocationManager()
    var userid = ""

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    
    @IBOutlet weak var submitBut: UIButton!
    @IBOutlet weak var screenid: UITextField!
    @IBOutlet weak var password: UITextField!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func sendSign(_ sender: Any) {
        sendSignUpRequest()
        print("DID IT")
    }
    
    
    
    func sendSignUpRequest(){
            //create the url with URL
            var request = URLRequest(url: URL(string: urlbase + "new_user_info")!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let name = self.name.text
        let password = self.password.text
        let screenid = self.screenid.text

        let parameters = ["name":name!, "password": password!,"screenid": screenid,"phone":phoneNumber.text!,"token":token] as! Dictionary<String, String>
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
            Alamofire.request(request).responseJSON { (response) in
                if response.description == "You were right!"{
                    // NEED TO FIX
                    //self.userid = Int(response.description)!
                    // might work but not sure we'll need to double check this
                }
                // have it flash notification that ur atempt was not correct
            }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       name.delegate = self
        password.delegate = self
        screenid.delegate = self
        self.locationManager.delegate = self

        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.submitBut.layer.cornerRadius = 10
        self.submitBut.clipsToBounds = true
        self.submitBut.titleLabel?.adjustsFontSizeToFitWidth = true
        
        // Do any additional setup after loading the view, typically from a nib.
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

extension SignUp: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let _: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    }
}

