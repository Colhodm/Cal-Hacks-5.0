//
//  MainViewController.swift
//  Cal-Hacks-TBD
//
//  Created by ananya mukerjee on 11/15/18.
//  Copyright © 2018 Cal-Hacks-5.0. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var myConstraint: NSLayoutConstraint!
    var sideMenuOpen = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(toggleSideMenu), name: NSNotification.Name(rawValue: "ToggleSideMenu"), object: nil)
    }
    @objc func toggleSideMenu(){
        print("IN HERE")
        if sideMenuOpen {
            myConstraint.constant = -240
            sideMenuOpen = false
        } else {
            myConstraint.constant = 0
            sideMenuOpen = true
        }
        UIView.animate(withDuration: 0.3, delay:0.0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: { finished in
            print("Basket doors opened!")
        })
        self.view.layoutIfNeeded()
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
