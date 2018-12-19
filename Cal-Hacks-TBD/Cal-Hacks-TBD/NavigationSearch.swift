//
//  NavigationSearch.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 12/19/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.
//

import UIKit

class NavigationSearch: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func switchLocText(_ sender: Any) {
        let temp = sender as! UITextField
        temp.text = "Start Location"
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
