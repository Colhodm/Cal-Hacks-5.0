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
class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstBox: UITextField!
    var locationManager = CLLocationManager()
    var userid = ""
    var logIn = false

    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var secondBox: UITextField!
    
    @IBOutlet weak var logInBut: UIButton!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func goToContracts(_ sender: Any) {
        self.performSegue(withIdentifier: "tempContractList", sender: self)
    }
    @IBAction func segToContract(_ sender: Any) {
           self.performSegue(withIdentifier: "createContract", sender: self)
    }
    @IBAction func login(_ sender: Any) {
        if ((firstBox.text?.count)! > 1 && (secondBox.text?.count)! > 2){
            sendLoginRequest()
    }
        // REMOVE WHEN ONLINE:
        self.userid = "101"
        self.logIn = true
        // might work but not sure we'll need to double check this
        self.performSegue(withIdentifier: "mapscreensegue", sender: self)
    
   
    
    }
    func sendLoginRequest(){
            //create the url with URL
            var request = URLRequest(url: URL(string: "http://54.193.17.183:5000/new_login")!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let name = firstBox.text
            let password = secondBox.text
        let parameters = ["name":name!, "password": password!] as! Dictionary<String, String>
        
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
            Alamofire.request(request).responseJSON { (response) in
                if response.value == nil{
                    return
                }
                let parameters = response.value! as? Dictionary<String, String>
                if parameters == nil{
                    return 
                }
                if (parameters!["id"] != "-1"){
                    self.userid = parameters!["id"]!
                    self.logIn = true
                    // might work but not sure we'll need to double check this
                    self.performSegue(withIdentifier: "mapscreensegue", sender: self)
                }
                // have it flash notification that ur atempt was not correct
            }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        firstBox.delegate = self
        secondBox.delegate = self
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.logInBut.layer.cornerRadius = 10
        self.logInBut.clipsToBounds = true
        self.logInBut.titleLabel?.adjustsFontSizeToFitWidth = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? MapViewController
        {
            vc.userid = userid
            vc.logIn = logIn
        }
        if let vc = segue.destination as? SignUp
        {
            //signUpBox.isHidden = true
        }
        if let vc = segue.destination as? LoginController
        {
            vc.userid = userid
        }
        if let vc = segue.destination as? contractsConfirm
        {
            vc.userID = userid
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    }
}

