//
//  contractsStatus.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 11/3/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.
//
//
//  contractsConfirm.swift
//
//
//  Created by ananya mukerjee on 11/3/18.
//
import UIKit
import Alamofire
import GooglePlaces
class contractsStatus: UIViewController {
    var contractID = ""
    var userID = ""
    var myTemp = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeGetRequest()
        // Do any additional setup after loading the view, typically from a nib.
    }
    @objc func makeGetRequest(){
        //create the url with URL
        var request = URLRequest(url: URL(string: "http://54.193.17.183:5000/get_owner_contract")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = ["userID": userID] as Dictionary<String, String>
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        Alamofire.request(request).responseJSON { (response) in
            print(response)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
