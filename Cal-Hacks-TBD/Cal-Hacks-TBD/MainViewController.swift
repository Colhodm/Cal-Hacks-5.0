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
    @IBOutlet weak var myMap: UIView!
    var sideMenuOpen = false
    var myMask: UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        print("RELOADED")
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(toggleSideMenu), name: NSNotification.Name(rawValue: "ToggleSideMenu"), object: nil)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:)))
        myMap.addGestureRecognizer(tapRecognizer)
        tapRecognizer.delegate = self
        self.myMap.isUserInteractionEnabled = true
    }
    @objc func tapped(gestureRecognizer: UITapGestureRecognizer) {
        print("SHOULD BE RUNNING")
        // Remove the blue view.
        if sideMenuOpen{
        toggleSideMenu()
        }
    }
    @objc func toggleSideMenu(){
        print("XXX")
        print("IN HERE")
        print(myConstraint.constant)
        if sideMenuOpen {
            // NOTE THIS WILL BREAK IF THE ORDER SWITCHES BUT SHOULD BE ALRIGHT FOR NOW
            self.myMap.subviews[0].subviews[0].subviews[0].isHidden = false
            myConstraint.constant = -240
            self.myMap.mask = myMask
            sideMenuOpen = false
        } else {
            print("SHOULD HAVE RAN THIS")
            myConstraint.constant = 0
            myMask = self.myMap.mask
            self.myMap.mask = UIView(frame: myMap.frame)
            self.myMap.mask?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            print(myConstraint.constant)
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
extension MainViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.superview!.superclass! .isSubclass(of: UIButton.self) {
            return false
        }
        return true
    }
}
