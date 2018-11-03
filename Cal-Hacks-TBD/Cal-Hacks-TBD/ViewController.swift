//
//  ViewController.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 11/2/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.
//

import UIKit
import GooglePlaces
class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstBox: UITextField!
    var locationManager = CLLocationManager()


    @IBOutlet weak var secondBox: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("RUNNING?")
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstBox.delegate = self
        secondBox.delegate = self
        self.locationManager.delegate = self

        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
       // if let vc = segue.destination as? page2
       // {
        //    vc.numPeople = Int(firstBox.text!)!
         //   vc.distance = Int(secondBox.text!)!
         //   vc.myPlacesSoFar = [GooglePlaces.GMSPlace]()
       // }
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

