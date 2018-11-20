//
//  mySideBarParent.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 11/19/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.
//

import UIKit

class mySideBarParent: UIViewController {

    @IBAction func myProfile(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
