//
//  PossibleContracts.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 12/17/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.
//

import UIKit
import Alamofire

class PossibleContracts: UIViewController {
    
    var contractID = ""
    var userID = ""
    var myTemp = [String]()
    var another = [String]()
    var myTempBackup = [String]()
    var anotherBackup = [String]()
    var myTempPrices = [String]()
    var myBackupPrices = [String]()
    @IBOutlet weak var myOptions: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myOptions.delegate = self
        self.myOptions.dataSource = self
        self.myOptions.isScrollEnabled = true;
        makeGetRequest()
        self.myOptions.reloadData()
        print("LOADED THE CONTRACTS CONFIRM PAGE")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let vc = segue.destination as? contractsStatus
        {
            vc.userID = userID
            vc.contractID = contractID
        }
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
                let another = myCurrent!["active"] as! Bool
                if temp
                {
                    self.another.append(contract_id!["$oid"] as! String)
                    let title = myCurrent!["title"]
                    self.anotherBackup.append(title as! String)
                    self.myBackupPrices.append(String(price as! Int!))
                } else if another {
                    self.myTemp.append(contract_id!["$oid"] as! String)
                    let title = myCurrent!["title"]
                    self.myTempBackup.append(title as! String)
                    self.myTempPrices.append(String(price as! Int!))
                }
            }
            self.myOptions.reloadData()
        }
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
class HeadlineTableViewCell: UITableViewCell{
    @IBOutlet weak var myImage: UIImageView!
    
    @IBOutlet weak var myAmount: UILabel!
    @IBOutlet weak var myReqItem: UILabel!
    @IBOutlet weak var myReqName: UILabel!
}


extension PossibleContracts: UITableViewDelegate,UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int {
            switch (section) {
            case 0:
                return self.myTemp.count
            case 1:
                return self.another.count
            default:
                print("WHAT AM I DOING HERE"
                )
                return self.myTemp.count
            }
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var temp = "myArray"
//        var cell = tableView.dequeueReusableCell(withIdentifier: "StoreCell") as? HeadlineTableViewCell
//        if cell == nil{
//            cell = HeadlineTableViewCell(style: .default, reuseIdentifier: temp)
//        }
        let cell:HeadlineTableViewCell = self.myOptions.dequeueReusableCell(withIdentifier:"cell") as! HeadlineTableViewCell

        switch (indexPath.section) {
        case 0:
            if (self.myTemp.count > 0){
                cell.myReqName?.text = myTempBackup[indexPath.row]
                cell.myAmount?.text = "Earn " + "$" + myTempPrices[indexPath.row]
            }
        case 1:
            if (self.another.count > 0){
                cell.myReqName?.text = anotherBackup[indexPath.row]
                cell.myAmount?.text = "Earn " + "$" + myBackupPrices[indexPath.row]
            }
        default:
            cell.myReqName?.text = "The id is "   + another[indexPath.row] + " the description is  " + myTemp[indexPath.row]
        }
        return cell
    }
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sections = ["Pending", "Yet to be Assigned"]
        return sections[section]
        
    }
     func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let cell = tableView.cellForRow(at: indexPath!)! as! HeadlineTableViewCell
        // Fix these properties and stuff but in a bit
        var temp = ""
        var flag = false
        if indexPath?.section == 0{
            temp = another[(indexPath?.row)!]
        }
        else{
            temp = myTemp[(indexPath?.row)!]
        }
        contractID = temp
        self.performSegue(withIdentifier: "finalCellDown", sender: self)
        
    }
    
    
}
