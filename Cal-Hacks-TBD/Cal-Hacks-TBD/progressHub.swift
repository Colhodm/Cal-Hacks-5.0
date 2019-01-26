//
//  progressHub.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 12/22/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire
class progressHub: UIViewController {
    var contractID = ""
    var userID = finaluserid
    var clickedContractID = ""
    var myTemp = [String]()
    var myTempBackup = [String]()
    var myTempPrices = [String]()
    var myTempDescription = [String]()
    var myPhone: String?

    var timer = Timer()

    @IBOutlet weak var myOptions: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myOptions.delegate = self
        self.myOptions.dataSource = self
        self.myOptions.isScrollEnabled = true;
        makeGetRequest()
        scheduledTimerWithTimeInterval()
        self.myOptions.reloadData()
        print(self.view.gestureRecognizers)
       // UNUserNotificationCenter.current().delegate = self

        // Do any additional setup after loading the view.
    }
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: Selector("makeGetRequest"), userInfo: nil, repeats: true)
    }
    @objc func makeGetRequest(){
        //create the url with URL
        var request = URLRequest(url: URL(string: urlbase + "get_owner_contract")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = ["userID": userID!] 
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        Alamofire.request(request).responseJSON { (response) in
            let names = response.value! as? [Any]
            if names == nil{
                return
            }
            for name in names! {
                
                let myCurrent = name as? Dictionary<String,Any>
                // TODO fix server so that it sends back the description of the request
                //print(myCurrent)
                let start_location = myCurrent!["startLocation"] as? [Double]
                let end_location = myCurrent!["endlocation"] as? [Double]
                let contract_id = myCurrent!["_id"] as? Dictionary<String,Any>
                let validity = myCurrent!["valid"]
                let price = myCurrent!["price"]
                let temp = validity as! Bool
                let description = myCurrent!["description"]
                // need to implement another array to store the phone numbers just like the rest of the information
                self.myPhone = myCurrent!["phoneNumber"] as! String!
                let another = myCurrent!["active"] as! Bool
          
                if !temp && another
                {
                    if !self.myTemp.contains((contract_id!["$oid"] as! String)){
                    self.myTemp.append(contract_id!["$oid"] as! String)
                    let title = myCurrent!["title"]
                    self.myTempBackup.append(title as! String)
                    self.myTempDescription.append(description as! String)
                    self.myTempPrices.append(String(price as! Int!))
                    }
                }
            }
            self.myOptions.reloadData()
        }
        
    }

    @IBAction func unWindToMap(_ sender: Any) {
        performSegue(withIdentifier: "BackToMap", sender: self)

    }
    
    @IBAction func unwindFromDrivers(segue:UIStoryboardSegue){
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? trackDriver
        {
            vc.contractid = self.clickedContractID
            vc.myPhone = self.myPhone
        }
    }

}
class HeadlineTableViewCellTwo: UITableViewCell{
    var myContractID: String?
    @IBOutlet weak var myImage: UIImageView!
    
    @IBOutlet weak var myReqName: UILabel!
    @IBOutlet weak var myReqItem: UILabel!
    
    @IBOutlet weak var myAmount: UILabel!
    @IBAction func cancel(_ sender: Any) {
        cancel(contractID: self.myContractID!)
    }
    
    
    
}

extension progressHub: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int {
            return self.myTemp.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HeadlineTableViewCellTwo = self.myOptions.dequeueReusableCell(withIdentifier:"cell") as! HeadlineTableViewCellTwo
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        
        let cell = tableView.cellForRow(at: indexPath!)! as! HeadlineTableViewCell
        print(cell.frame)
        self.clickedContractID = cell.myContractID!
        performSegue(withIdentifier: "toTrack", sender: self)
    }
}

//
//extension progressHub:UNUserNotificationCenterDelegate{
//    func userNotificationCenter(
//        _ center: UNUserNotificationCenter,
//        didReceive response: UNNotificationResponse,
//        withCompletionHandler completionHandler: @escaping () -> Void) {
//        print("some update occured here")
//
//        // 4
//        completionHandler()
//    }
//}
