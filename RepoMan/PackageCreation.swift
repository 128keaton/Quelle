//
//  PackageCreation.swift
//  RepoMan
//
//  Created by Keaton Burleson on 1/2/17.
//  Copyright © 2017 Keaton Burleson. All rights reserved.
//

import Foundation
import Cocoa

class PackageCreation: UIViewController, DestinationViewDelegate {
    @IBOutlet var destinationView: DestinationView!
    @IBOutlet var folderTitleButton: NSButton?
    @IBOutlet var createButton: NSButton?
    @IBOutlet var nameField: NSTextField?
    var packagePath: String!
    var packageURL: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = dpkgExists()
        destinationView.delegate = self


    }
    override func viewDidAppear() {
        self.view.window!.title = "Create a package"
    }

    func dpkgExists() -> Bool {

        let task = Process()
        task.launchPath = "/usr/local/bin/dpkg"
        task.arguments = ["--version"]


        let pipe = Pipe()
        task.standardOutput = pipe


        task.launch()


        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)

        if ((output?.range(of: "Debian 'dpkg'")) != nil) {
            print("dpkg exists!!")

            return true
        }
        print("dpkg doesn't exist :(")
        let _ = displayError(title: "Whoops!", text: "Try installing Homebrew first")

        return false

    }
    func process(path: String) {
        self.packageURL = URL(string: path)
        self.packagePath = path
        folderTitleButton?.isEnabled = true
        createButton?.isEnabled = true
    }
    @IBAction func initiatePackageCreation(sender: NSButton) {
        var packageTitle: String? = nil
        if (self.packageURL != nil) && packagePath != nil {
            if self.nameField?.stringValue != "" {
                packageTitle = self.nameField?.stringValue
            } else {
                packageTitle = packageURL.lastPathComponent
            }
            createPackage(folder: packagePath, name: packageTitle!)
        } else {
            let _ = displayError(title: "Couldn't set package path", text: "Make sure the folder exists!")
        }
    }
    @IBAction func useFolderTitle(sender: NSButton) {
        nameField?.stringValue = self.packageURL.lastPathComponent
    }
    
    @IBAction func dismiss(sender: NSButton){
        self.dismiss(self)
    }
    func createPackage(folder: String, name: String) {

        // edit title
        let controlFilePath = "file://" + folder + "/DEBIAN/control"

        var controlFile: String? = nil
        var controlFileLines: [String]? = nil
        do {
            controlFile = try String(contentsOf: URL(string: controlFilePath)!)
        } catch let error as NSError {
            let _ = displayError(title: "Failed to create package", text: error.localizedDescription)
        } catch _ {
            let _ = displayError(title: "Failed to create package", text: "Could not get control file")
        }
        controlFileLines = controlFile?.components(separatedBy: NSCharacterSet.newlines)

        for line in controlFileLines! {
            if (line.range(of: "Name:") != nil || line == "") {
                controlFileLines?.remove(at: (controlFileLines?.index(of: line))!)
            }
        }
        controlFileLines?.append("Name: \(name)")

        print(controlFileLines ?? "No lines")
        controlFile = ""
        for line in controlFileLines! {
            controlFile = controlFile! + line + "\n"
        }
        controlFile = controlFile! + "\n"

        do {
            try controlFile?.write(to: URL(string: controlFilePath)!, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            let _ = displayError(title: "Failed to create package", text: error.localizedDescription)
        }


        var outputFolder = ""
        if let localPath = UserDefaults.standard.object(forKey: "localDeb"){
            outputFolder = (localPath as! String).replacingOccurrences(of: "file://", with: "")
            print(outputFolder)
        }
        let task = Process()
        task.launchPath = "/usr/local/bin/dpkg-deb"
        task.arguments = ["-Zgzip", "-b", folder, outputFolder]


        let pipe = Pipe()
        task.standardOutput = pipe


        task.launch()
        task.waitUntilExit()


        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
       
        if ((output?.range(of: "building package")) == nil) {
            let _ = displayError(title: "Failed to create package", text: output! as String)
            print(output ?? "??")
        } else {
            displayMessage(title: "Created package", text: (output?.replacingOccurrences(of: "dpkg-deb: ", with: "").capitalizingFirstLetter())!)
        }

    }





}
