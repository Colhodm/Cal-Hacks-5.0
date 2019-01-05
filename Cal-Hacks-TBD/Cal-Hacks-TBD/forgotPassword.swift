//
//  forgotPassword.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 12/29/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.
//

import UIKit
import Alamofire
import Stripe


class forgotPassword: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var firstBox: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        firstBox.delegate = self

        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func sendForgotRequest(sender: UITextField){
        //create the url with URL
        var request = URLRequest(url: URL(string: urlbase + "forgot_password")!)
        request.httpMethod = HTTPMethod.post.rawValue
        print("MIDDLE")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let email = sender.text
        let parameters = ["name":email!] as! Dictionary<String, String>
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
            // have it flash notification that ur atempt was not correct
        }
    }
    
    @IBAction func emailCompleted(_ sender: Any) {
        sendForgotRequest(sender: sender as! UITextField)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
