//
//  PreferencesController.swift
//  Quelle
//
//  Created by Keaton Burleson on 1/3/17.
//  Copyright © 2017 Keaton Burleson. All rights reserved.
//

import Foundation
import AppKit

class Preferences: NSViewController {
    let defaults = UserDefaults.standard
    @IBOutlet var localFilePath: NSTextField?
    @IBOutlet var debOutputFolderPath: NSTextField?


    override func viewDidLoad() {
        if let path = defaults.object(forKey: "localURL") {
            localFilePath?.stringValue = (path as! String).replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: NSHomeDirectory(), with: "~")
        }
        if let deb = defaults.object(forKey: "localDeb") {
            debOutputFolderPath?.stringValue = (deb as! String).replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: NSHomeDirectory(), with: "~")
        }

    }
    

    @IBAction func browseFileSystem(sender: NSButton) {
        let openDialog = NSOpenPanel()
        openDialog.canChooseFiles = false
        openDialog.canChooseDirectories = true
        openDialog.allowsMultipleSelection = false
        openDialog.directoryURL = URL(string: "file:///" + NSHomeDirectory())
        if openDialog.runModal() == NSModalResponseOK {
            switch sender.tag {
            case 0:
                defaults.set(openDialog.urls[0].relativeString, forKey: "localURL")
                localFilePath?.stringValue = openDialog.urls[0].relativeString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: NSHomeDirectory(), with: "~")

            case 1:
                defaults.set(openDialog.urls[0].relativeString, forKey: "localDeb")
                debOutputFolderPath?.stringValue = openDialog.urls[0].relativeString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: NSHomeDirectory(), with: "~")

            default:
                defaults.set(openDialog.urls[0].relativeString, forKey: "localURL")
                localFilePath?.stringValue = openDialog.urls[0].relativeString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: NSHomeDirectory(), with: "~")

            }
            defaults.synchronize()
        }
    }
}
