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

    override func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SelectionScreen.performSegue(sender:)),
            name: NSNotification.Name(rawValue: "newDocument"),
            object: nil)
    }
}
