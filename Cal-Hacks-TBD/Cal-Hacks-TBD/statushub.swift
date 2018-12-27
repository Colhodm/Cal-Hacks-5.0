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
    var userID = ""
    var another = [String]()
    var anotherBackup = [String]()
    var myBackupPrices = [String]()

    @IBOutlet weak var myOptions: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myOptions.delegate = self
        self.myOptions.dataSource = self
        self.myOptions.isScrollEnabled = true;
        makeGetRequest()
        self.myOptions.reloadData()
        print("RAN SOME STUFF")

        // Do any additional setup after loading the view.
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


extension statushub: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
        Int {
            return self.another.count
            }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HeadlineTableViewCell = self.myOptions.dequeueReusableCell(withIdentifier:"cell") as! HeadlineTableViewCell
            if (self.anotherBackup.count > 0){
                cell.myReqName?.text = anotherBackup[indexPath.row]
                cell.myAmount?.text = "Earn " + "$" + myBackupPrices[indexPath.row]
            }
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
