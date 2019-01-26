//
//  statushub.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 12/22/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.
//

import UIKit
import Alamofire

class statushub: UIViewController {
    var contractID = ""
    var userID = finaluserid
    var timer = Timer()

    var another = [String]()
    var anotherBackup = [String]()
    var myBackupPrices = [String]()
    var anotherDescription = [String]()

    @IBOutlet var myMasterView: UIView!
    
    @IBOutlet weak var myOptions: UITableView!
    @IBAction func ButtonTaped(_ sender: Any) {
        print("IM BEING TAPPED SUCCESFULLY")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myOptions.delegate = self
        self.myOptions.dataSource = self
        self.myOptions.isScrollEnabled = true;
        makeGetRequest()
        scheduledTimerWithTimeInterval()
        self.myOptions.reloadData()
        print("XXXXXX")
        print(self.view)
        print(self.myMasterView)
        print(self.myMasterView.gestureRecognizers)
        print("XXXXXX")
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
                if temp
                {
                    if !self.another.contains((contract_id!["$oid"] as! String)){
                    self.another.append(contract_id!["$oid"] as! String)
                    let title = myCurrent!["title"]
                    self.anotherBackup.append(title as! String)
                    self.anotherDescription.append(description as! String)
                    self.myBackupPrices.append(String(price as! Int!))
                    }
                    // Don't need this else currently in this viewcontroller
                }
            }
            self.myOptions.reloadData()
        }
    }
 
    @IBAction func unwindToMap(_ sender: Any) {
   performSegue(withIdentifier: "unwindStatusHub", sender: self)
    }
    

    
}
class HeadlineTableViewCellOne: UITableViewCell{
    var myContractID: String?
    @IBOutlet weak var myImage: UIImageView!
    @IBOutlet weak var myReqName: UILabel!
    @IBOutlet weak var myReqItem: UILabel!
    
    @IBAction func cancel(_ sender: Any) {
        cancel(contractID: self.myContractID!)
    }
    
    
    @IBOutlet weak var myAmount: UILabel!
}

extension statushub: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int {
            return self.another.count
            }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HeadlineTableViewCellOne = self.myOptions.dequeueReusableCell(withIdentifier:"cell") as! HeadlineTableViewCellOne
            if (self.anotherBackup.count > 0){
                print("SETTING UP STUFF")
                
                cell.myContractID = another[indexPath.row]
                cell.myReqName?.text = anotherBackup[indexPath.row]
                // TODO ADD THE DSCRIPTION TO THIS
                cell.myReqItem?.text = anotherDescription[indexPath.row]
                cell.myAmount?.text = "Earn " + "$" + myBackupPrices[indexPath.row]
            }
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}


extension UITableViewCell {
    func cancel(contractID: String){
        var request = URLRequest(url: URL(string: urlbase + "cancel_contract")!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = ["contractID": contractID]
        
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
        
    }
}
}
