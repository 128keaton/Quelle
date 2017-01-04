//
//  HomebrewInstaller.swift
//  RepoMan
//
//  Created by Keaton Burleson on 1/3/17.
//  Copyright © 2017 Keaton Burleson. All rights reserved.
//

import Foundation
import Cocoa
class HomebrewInstaller: NSViewController {

    @IBOutlet var outputView: NSTextView?
    @IBOutlet var statusLabel: NSTextField?
    @IBOutlet var closeButton: NSButton?

    @IBOutlet var homebrewIcon: NSImageView?
    @IBOutlet var dpkgIcon: NSImageView?
    
    override func viewDidLoad() {
        outputView?.string = ""
        outputView?.textColor = NSColor.green
        DispatchQueue.global(qos: .background).async {
            let homebrewStatus = self.isHomebrewInstalled()
            let dpkgStatus = self.isDpkgInstalled()


            DispatchQueue.main.async {
                if dpkgStatus == false && homebrewStatus == true {
                    DispatchQueue.global(qos: .background).async {
                        self.installDPKG()
                    }
                }
              
            }

        }


    }

    @IBAction func manuallyInstallDPKG(sender: NSButton){
        DispatchQueue.global(qos: .background).async {
            self.installDPKG()
        }
    }
    func installDPKG() {
        closeButton?.isEnabled = false
        let task = Process()
        task.launchPath = "/usr/local/bin/brew"

        task.arguments = [ "install", "dpkg"]

        print("Trying to install dpkg")
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe


        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(receivedData(notif:)), name: NSNotification.Name.NSFileHandleDataAvailable, object: outHandle)

        // You can also set a function to fire after the task terminates
        task.terminationHandler = { task -> Void in
            // Handle the task ending here
        }



        task.launch()

        task.waitUntilExit()


        closeButton?.isEnabled = true

    }

    func receivedData(notif: NSNotification) {
        let fh: FileHandle = notif.object as! FileHandle

        let data = fh.availableData



        fh.waitForDataInBackgroundAndNotify()
        fh.readDataToEndOfFile()
        let string = NSString(data: data, encoding: String.Encoding.ascii.rawValue)
        outputView?.string = outputView?.string?.appending( (string as String?)!)


    }


    func isHomebrewInstalled() -> Bool {
        let task = Process()
        task.launchPath = "/usr/local/bin/brew"
        task.arguments = ["-v"]


        let pipe = Pipe()
        task.standardOutput = pipe


        task.launch()


        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)

        if ((output?.range(of: "homebrew-core")) != nil) {
            print("Homebrew exists")
            statusLabel?.stringValue = (statusLabel?.stringValue.replacingOccurrences(of: "Homebrew is not installed", with: "Homebrew is installed"))!
            return true
        }

        let _ = displayError(title: "Whoops!", text: "Try installing Homebrew first")

        return false

    }
    func isDpkgInstalled() -> Bool {

        let task = Process()
        task.launchPath = "/usr/local/bin/dpkg"
        task.arguments = ["--version"]


        let pipe = Pipe()
        task.standardOutput = pipe


        task.launch()


        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)

        if ((output?.range(of: "Debian 'dpkg'")) != nil) {

            statusLabel?.stringValue = (statusLabel?.stringValue.replacingOccurrences(of: "dpkg is not installed", with: "dpkg is installed"))!
            return true
        }
        print("dpkg doesn't exist :(")
        let _ = displayError(title: "Whoops!", text: "Try installing Homebrew first")

        return false

    }

}
