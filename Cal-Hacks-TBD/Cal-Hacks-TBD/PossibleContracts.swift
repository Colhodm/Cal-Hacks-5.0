//
//  PossibleContracts.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 12/17/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMaps
class PossibleContracts: UIViewController {
    var timer = Timer()
    var contractID = ""
    var userID = finaluserid
    var myTemp = [String]()
    var myTempBackup = [String]()
    var myTempDescription = [String]()
    var myTempPrices = [String]()
    var finalDest = ""
    var locationManager = CLLocationManager()
    @IBOutlet weak var myOptions: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myOptions.delegate = self
        self.myOptions.dataSource = self
        self.myOptions.isScrollEnabled = true;
        scheduledTimerWithTimeInterval()
        makeGetRequest()
        self.myOptions.reloadData()
        print("LOADED THE CONTRACTS CONFIRM PAGE")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: Selector("makeGetRequest"), userInfo: nil, repeats: true)
    }
    @objc func makeGetRequest(){
        //create the url with URL
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
            let owner_id = myCurrent!["ownerID"] as! String!
            let validity = myCurrent!["valid"] as! Bool
            let price = myCurrent!["price"]
            let description = myCurrent!["description"]
            let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(start_location![0]), longitude: CLLocationDegrees(start_location![1]))
            if (!myTemp.contains((contract_id!["$oid"] as! String)) && validity && (finaluserid != owner_id)){
            self.myTemp.append(contract_id!["$oid"] as! String)
            let title = myCurrent!["title"]
            self.myTempBackup.append(title as! String)
            self.myTempDescription.append(description as! String)
            self.myTempPrices.append(String(price as! Int!))
            }
        }
        self.myOptions.reloadData()
    }
    
}


class HeadlineTableViewCell: UITableViewCell{
    @IBOutlet weak var myImage: UIImageView!
    var myContractID: String?
    @IBOutlet weak var myAmount: UILabel!
  
    @IBOutlet weak var myReqItem: UILabel!
    @IBOutlet weak var myReqName: UILabel!
}


extension PossibleContracts: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int {
            return self.myTemp.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HeadlineTableViewCell = self.myOptions.dequeueReusableCell(withIdentifier:"cell") as! HeadlineTableViewCell
        if (self.myTemp.count > 0){
            cell.myContractID = myTemp[indexPath.row]
            cell.myReqName?.text = myTempBackup[indexPath.row]
            cell.myAmount?.text = "Earn " + "$" + myTempPrices[indexPath.row]
            cell.myReqItem?.text = myTempDescription[indexPath.row]
        }
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
