//
//  RepositoryManagement.swift
//  Quelle
//
//  Created by Keaton Burleson on 1/3/17.
//  Copyright © 2017 Keaton Burleson. All rights reserved.
//

import Foundation
import Cocoa
class RepositoryManagement: NSViewController, DestinationViewDelegate {
    var previewPane: PreviewPane?
    @IBOutlet var originField: NSTextField?
    @IBOutlet var labelField: NSTextField?
    @IBOutlet var codenameField: NSTextField?
    @IBOutlet var descriptionField: NSTextField?

    @IBOutlet var urlField: NSTextField?
    @IBOutlet var iconDrop: DestinationView?

    override func viewDidLoad() {
        iconDrop?.labelText = "drop icon here"
        iconDrop?.conformanceType = String(kUTTypeImage)
        iconDrop?.delegate = self
        parseReleaseFile()
    }
    override func viewDidAppear() {
        previewPane = self.parent?.childViewControllers[1] as? PreviewPane
    }
    @IBAction func saveFields(sender: NSButton) {
        previewPane?.originLabel?.stringValue = "Origin: " + (originField?.stringValue)!
        previewPane?.labelLabel?.stringValue = "Label: " + (labelField?.stringValue)!
        previewPane?.codenameLabel?.stringValue = "Codename: " + (codenameField?.stringValue)!
        previewPane?.descriptionLabel?.stringValue = "Description: " + (descriptionField?.stringValue)!

        previewPane?.repoLabel?.stringValue = (labelField?.stringValue)!
        previewPane?.urlLabel?.stringValue = (urlField?.stringValue)!
        
        if !saveReleaseFile() && UserDefaults.standard.object(forKey: "localURL") != nil{
            let _ = displayError(title: "Couldn't save release file", text: "Check the logs for more information")
        }
    }
    func parseReleaseFile() {
        if let localPath = UserDefaults.standard.object(forKey: "localURL") {
            if let releaseFileLines = readReleaseFile(path: (localPath as! String).appending("/Release")) {
                for line in releaseFileLines {
                    if line.contains("Label: ") {
                        previewPane?.labelLabel?.stringValue = line
                        labelField?.stringValue = line
                    } else if line.contains("Codename: ") {
                        previewPane?.codenameLabel?.stringValue = line
                        codenameField?.stringValue = line
                    } else if line.contains("Origin: ") {
                        previewPane?.originLabel?.stringValue = line
                        originField?.stringValue = line
                    } else if line.contains("Description: ") {
                        previewPane?.descriptionLabel?.stringValue = line
                        descriptionField?.stringValue = line
                    }
                }
            }
        }
    }
    func readReleaseFile(path: String) -> [String]? {
        if let localPath = UserDefaults.standard.object(forKey: "localURL") {

            let releaseFilePath = (localPath as! String).appending("/Release")
            var releaseFile: String? = nil
            var releaseFileLines: [String]? = nil
            do {
                releaseFile = try String(contentsOf: URL(string: releaseFilePath)!)
            } catch let error as NSError {
                if !error.localizedDescription.contains("because there is no such file.") {
                    let _ = displayError(title: "Failed to read release file", text: error.localizedDescription)
                }

            } catch _ {
                let _ = displayError(title: "Failed to read release file", text: "Could not get file")
            }
            releaseFileLines = releaseFile?.components(separatedBy: NSCharacterSet.newlines)

            return releaseFileLines

        } else {
            return nil
        }
    }
    func saveReleaseFile() -> Bool {
        var outputFolder = ""
        var releaseFileLines: [String]? = nil
        if let localPath = UserDefaults.standard.object(forKey: "localURL") {
            outputFolder = (localPath as! String).replacingOccurrences(of: "file://", with: "")
            print(outputFolder)
            let releaseFilePath = (localPath as! String) + "/Release"

            releaseFileLines = []



            releaseFileLines?.append((originField?.stringValue)!)

            releaseFileLines?.append((codenameField?.stringValue)!)

            releaseFileLines?.append((labelField?.stringValue)!)

            releaseFileLines?.append((descriptionField?.stringValue)!)

            releaseFileLines?.append("Suite: stable")
            releaseFileLines?.append("Version: 1.0")
            releaseFileLines?.append("Architectures: iphoneos-arm")
            releaseFileLines?.append("Components: main")

            print(releaseFileLines ?? "No lines")

            var releaseFile = ""
            for line in releaseFileLines! {
                releaseFile = releaseFile + line + "\n"
            }
            releaseFile = releaseFile + "\n"

            do {
                try releaseFile.write(to: URL(string: releaseFilePath)!, atomically: true, encoding: String.Encoding.utf8)
                return true
            } catch let error as NSError {
                let _ = displayError(title: "Failed to save release file", text: error.localizedDescription)

            }


        }
        return false



    }
    func process(path: String) {
        iconDrop?.labelText = ""
        iconDrop?.imageBackground = NSImage(contentsOfFile: path)
        previewPane?.iconView?.image = NSImage(contentsOfFile: path)
    }
}

class PreviewPane: NSViewController {

    @IBOutlet var originLabel: NSTextField?
    @IBOutlet var labelLabel: NSTextField?
    @IBOutlet var codenameLabel: NSTextField?
    @IBOutlet var descriptionLabel: NSTextField?

    @IBOutlet var repoLabel: NSTextField?
    @IBOutlet var urlLabel: NSTextField?
    @IBOutlet var iconView: NSImageView?

    var mainPane: RepositoryManagement?

    override func viewDidAppear() {
        mainPane = self.parent?.childViewControllers[0] as? RepositoryManagement
    }
    @IBAction func dismissParent(sender: NSButton) {
        self.parent?.dismiss(sender)
    }
}
