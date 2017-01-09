//
//  SelectionScreen.swift
//  RepoMan
//
//  Created by Keaton Burleson on 1/3/17.
//  Copyright © 2017 Keaton Burleson. All rights reserved.
//

import Foundation
import Cocoa
class SelectionScreen: UIViewController {
    
    var payPalURL = URL(string: "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=APUAYQK284R3C&lc=US&item_name=Keaton%20Burleson&item_number=Quelle&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted")
    var segues = [1: "makePackage"]
    @IBAction func performSegue(sender: AnyObject) {
       
        if sender.tag == nil{
            let index = ((sender as! Notification).object as! [String: Int])["tag"]
            
            self.performSegue(withIdentifier: segues[index!]!, sender: sender)
        }else{
            self.performSegue(withIdentifier: segues[sender.tag]!, sender: sender)
        }
        
      
    }
    func checkForSelf(){
        if(self != NSApplication.shared().windows[0].contentViewController) {
            print(NSApplication.shared().windows[0].contentViewController! )
            print(self)
        }
    }
    override func viewDidAppear() {

        checkForSelf()
    }
    
    @IBAction func newDocumentAction(sender: NSMenuItem){
        NotificationCenter.default.post(NSNotification.init(name: NSNotification.Name(rawValue: "newDocument"), object:  ["tag": 1]) as Notification)
    }

    @IBAction func openDonate(sender: NSButton){
        NSWorkspace().open(payPalURL!)
    }
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SelectionScreen.performSegue(sender:)),
            name: NSNotification.Name(rawValue: "newDocument"),
            object: nil)
    }
}
