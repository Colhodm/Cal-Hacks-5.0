//
//  stripeObj.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 1/1/19.
//  Copyright © 2019 Cal-Hacks-5.0. All rights reserved.
//

import Foundation
import Stripe
import Alamofire

class MyAPIClient: NSObject, STPEphemeralKeyProvider {
    
    static let sharedClient = MyAPIClient()
    var baseURLString: String? = nil
    var baseURL: URL {
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
    }
    
    func completeCharge(_ result: STPPaymentResult,
                        amount: Int,
                        shippingAddress: STPAddress?,
                        shippingMethod: PKShippingMethod?,
                        completion: @escaping STPErrorBlock) {
        print("TRYING TO VERIFY WITH BACKEND THAT I CAN DO TRANSACTION")
        let url = self.baseURL.appendingPathComponent("charge")
        var params = [
            "source": result.source.stripeID,
            "amount": amount
            ] as [String : Any]
        params["shipping"] = STPAddress.shippingInfoForCharge(with: shippingAddress, shippingMethod: shippingMethod)
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        Alamofire.request(request)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
    }
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = [
            "api_version": apiVersion,
            "userID": finaluserid,
            ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            
        } catch let error {
            print(error.localizedDescription)
        }
        Alamofire.request(request).validate(statusCode: 200..<300).responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    print("HEREZZZZZZ")
                    //let myResponse = responseJSON.value as? Dictionary<String,Any>
                    //print(myResponse)
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    print("TEET FAILURE")
                    completion(nil, error)
                }
        }
    }
    
}
