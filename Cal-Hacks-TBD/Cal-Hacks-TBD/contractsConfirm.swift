//
//  contractsConfirm.swift
//
//
//  Created by ananya mukerjee on 11/3/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.

import UIKit
import Alamofire
import GooglePlaces
class contractsConfirm: UITableViewController {
    var contractID = ""
    var userID = ""
    var myTemp = [String]()
    var another = [String]()
    var myTempBackup = [String]()
    var anotherBackup = [String]()


    override func viewDidLoad() {
        super.viewDidLoad()
        makeGetRequest()
        self.tableView.reloadData()


        //
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
        var request = URLRequest(url: URL(string: urlbase + "get_owner_contract")!)
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
                _ = myCurrent!["startLocation"] as? [Double]
                _ = myCurrent!["endlocation"] as? [Double]
                let contract_id = myCurrent!["_id"] as? Dictionary<String,Any>
                let validity = myCurrent!["valid"]
                _ = myCurrent!["price"]
                let temp = validity as! Bool
                let another = myCurrent!["active"] as! Bool
                if temp
                    {
                    self.another.append(contract_id!["$oid"] as! String)
                        let title = myCurrent!["title"]
                    self.anotherBackup.append(title as! String)
                } else if another {
                    self.myTemp.append(contract_id!["$oid"] as! String)
                    let title = myCurrent!["title"]
                    self.myTempBackup.append(title as! String)
                }
        }
            self.tableView.reloadData()
    }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
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
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let temp = "myArray"
        var cell = tableView.dequeueReusableCell(withIdentifier: "StoreCell")
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: temp)
        }
        switch (indexPath.section) {
        case 0:
            if (self.myTemp.count > 0){
            cell?.textLabel?.text = "The Title is  " + myTempBackup[indexPath.row]
            }
        case 1:
            if (self.another.count > 0){
                cell?.textLabel?.text = "The Title is  " + anotherBackup[indexPath.row]
            }
        default:
            cell?.textLabel?.text = "The id is "   + another[indexPath.row] + " the description is  " + myTemp[indexPath.row]
        }
        return cell!
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sections = ["Pending", "Yet to be Assigned"]
        return sections[section]

    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let cell = tableView.cellForRow(at: indexPath!)! as UITableViewCell
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


    


