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
public var finaluserid: String!
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
        if ((firstBox.text?.count)! >= 1 && (secondBox.text?.count)! >= 1){
            print("SENDING")
            sendLoginRequest()
    }
   
    }
    @IBAction func unWindSignUpHub(segue:UIStoryboardSegue) {
        
    }
    @IBAction func unWindForgotHub(segue:UIStoryboardSegue) {
        
    }
    
    @objc func applicationDidBecomeActive() {
        // Update your view controller
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.logInBut.layer.cornerRadius = 10
        self.logInBut.clipsToBounds = true
        self.logInBut.titleLabel?.adjustsFontSizeToFitWidth = true
        print(firstBox)
        print(secondBox)
        print("finished running")
        
        
    }
    func sendLoginRequest(){
            //create the url with URL
            print("DEBUGGING")
            var request = URLRequest(url: URL(string: "http://13.57.239.255:5000/new_login")!)
            request.httpMethod = HTTPMethod.post.rawValue
            print("MIDDLE")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let name = firstBox.text
            let password = secondBox.text
        let parameters = ["name":name!, "password": password!] as! Dictionary<String, String>
        print("SENT")
        
        
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
                print(parameters)
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive, // UIApplication.didBecomeActiveNotification for swift 4.2+
            object: nil)
        print("TESTING1")
        super.viewDidLoad()
        print("TESTING2")
        firstBox.delegate = self
        secondBox.delegate = self
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.logInBut.layer.cornerRadius = 10
        self.logInBut.clipsToBounds = true
        self.logInBut.titleLabel?.adjustsFontSizeToFitWidth = true
        print("I FINISHED LOADING")
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {

        if let vc = segue.destination as? SignUp
        {
            //signUpBox.isHidden = true
        }
        if let vc = segue.destination as? LoginController
        {
            vc.userid = userid
        }
        if let vc = segue.destination as? MainViewController
        {
             finaluserid = userid
        }
        if let vc = segue.destination as? contractsConfirm
        {
            vc.userID = userid
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("AM I RANDOMLY IN HERE")
    }
    
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    }
}

