//
//  contractsConfirm.swift
//
//
//  Created by ananya mukerjee on 11/3/18.
//

import UIKit
import Alamofire
import GooglePlaces
class contractsConfirm: UITableViewController {
    var contractID = ""
    var userID = ""
    var myTemp = [String]()
    var another = [String]()


    override func viewDidLoad() {
        super.viewDidLoad()
        makeGetRequest()
        self.tableView.reloadData()


        //
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
            for name in names! {
                )
                let myCurrent = name as? Dictionary<String,Any>
                let start_location = myCurrent!["startLocation"] as? [Double]
                let end_location = myCurrent!["endlocation"] as? [Double]
                let contract_id = myCurrent!["_id"] as? Dictionary<String,Any>
                let validity = myCurrent!["valid"]
                let price = myCurrent!["price"]
                self.another.append(contract_id!["$oid"] as! String)
                self.myTemp.append((myCurrent!["description"] as? String)!)
                let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(start_location![0]), longitude: CLLocationDegrees(start_location![1]))
        }
            self.tableView.reloadData()
    }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myTemp.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let temp = "myArray"
        var cell = tableView.dequeueReusableCell(withIdentifier: temp)
        if cell == nil{
            cell = UITableViewCell(style: .default, reuseIdentifier: temp)
        }
        // FIX ME INDEX OUT OF RANGE ERROR
        print("AM I EVEN RUNNING???")
        cell?.textLabel?.text = myTemp[indexPath.row] + " The description is  " + another[indexPath.row]
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("could i be called")
        let indexPath = tableView.indexPathForSelectedRow
        let cell = tableView.cellForRow(at: indexPath!)! as UITableViewCell
    }
    

    
}


    


