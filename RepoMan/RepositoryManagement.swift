//
//  RepositoryManagement.swift
//  Quelle
//
//  Created by Keaton Burleson on 1/3/17.
//  Copyright © 2017 Keaton Burleson. All rights reserved.
//

import Foundation
import Cocoa
class RepositoryManagement: NSViewController, DestinationViewDelegate, NSTextFieldDelegate {
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
        
        originField?.delegate = self
        labelField?.delegate = self
        codenameField?.delegate = self
        descriptionField?.delegate = self
        urlField?.delegate = self
        
    }
    override func viewDidAppear() {
        previewPane = self.parent?.childViewControllers[1] as? PreviewPane
        parseReleaseFile()
        checkForIcon()
    }
 
    func updateFields(){
        previewPane?.originLabel?.stringValue = "Origin: " + (originField?.stringValue)!
        previewPane?.labelLabel?.stringValue = "Label: " + (labelField?.stringValue)!
        previewPane?.codenameLabel?.stringValue = "Codename: " + (codenameField?.stringValue)!
        previewPane?.descriptionLabel?.stringValue = "Description: " + (descriptionField?.stringValue)!
        
        previewPane?.repoLabel?.stringValue = (labelField?.stringValue)!
        previewPane?.urlLabel?.stringValue = (urlField?.stringValue)!
        
        if !saveReleaseFile() && UserDefaults.standard.object(forKey: "localURL") != nil {
            let _ = displayError(title: "Couldn't save release file", text: "Check the logs for more information")
        }

    }
    override func controlTextDidChange(_ obj: Notification) {
        updateFields()
    }
    
    func checkForIcon(){
        if let localPath = UserDefaults.standard.object(forKey: "localURL") {
            print((localPath as! String) + "CydiaIcon.png")
            self.process(path: (localPath as! String).replacingOccurrences(of: "file://", with: "") + "CydiaIcon.png")
        }

    }
   
    
    
    func parseReleaseFile() {
        if let localPath = UserDefaults.standard.object(forKey: "localURL") {
            if let releaseFileLines = readReleaseFile(path: (localPath as! String).appending("/Release")) {
                for line in releaseFileLines {
                    if line.contains("Label: ") {
                        labelField?.stringValue = line.replacingOccurrences(of: "Label: ", with: "")
                        previewPane?.repoLabel?.stringValue = (labelField?.stringValue)!
                        previewPane?.setLabel(label: (labelField?.stringValue)!)
                    } else if line.contains("Codename: ") {
                        codenameField?.stringValue = line.replacingOccurrences(of: "Codename: ", with: "")
                        previewPane?.setCodename(codename: (codenameField?.stringValue)!)
                    } else if line.contains("Origin: ") {
                        originField?.stringValue = line.replacingOccurrences(of: "Origin: ", with: "")
                        previewPane?.setOrigin(origin: (originField?.stringValue)!)
                    } else if line.contains("Description: ") {
                        descriptionField?.stringValue = line.replacingOccurrences(of: "Description: ", with: "")
                        previewPane?.setDescription(description: (descriptionField?.stringValue)!)
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



            releaseFileLines?.append("Origin: " + (originField?.stringValue)!)

            releaseFileLines?.append("Codename: " + (codenameField?.stringValue)!)

            releaseFileLines?.append("Label: " + (labelField?.stringValue)!)

            releaseFileLines?.append("Description: " + (descriptionField?.stringValue)!)

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
        if let icon = NSImage(contentsOfFile: path){
            print("we can image: " + path)
            iconDrop?.labelText = ""
            iconDrop?.imageBackground = icon
            previewPane?.iconView?.image = icon
            let _ =  saveImageSizes(image: icon)
        }
      

    }
    func saveImageSizes(image: NSImage) -> Bool {
        if let localPath = UserDefaults.standard.object(forKey: "localURL") {
            let regularIcon = self.resizeImage(image: image, targetSize: CGSize(width: 32, height: 32))
            let retinaIcon = self.resizeImage(image: image, targetSize: CGSize(width: 64, height: 64))
            let largeAssIcon = self.resizeImage(image: image, targetSize: CGSize(width: 96, height: 96))

            let icons = ["CydiaIcon.png": regularIcon, "CydiaIcon@2x.png": retinaIcon, "CydiaIcon@3x.png": largeAssIcon]


            for icon in icons.keys {
                let iconPath = (localPath as! String)  + icon
                let actualImage = icons[icon]
                let imageURL = URL(string: iconPath)
                print(iconPath)
                actualImage?.lockFocus()
                let whyCocoa = NSBitmapImageRep(focusedViewRect: NSRect(x: 0.0, y: 0.0, width: actualImage!.size.width, height: image.size.height))
                actualImage?.unlockFocus()
                if let imageData = whyCocoa?.representation(using: .PNG, properties: [:]) {
                    do{
            
                        try imageData.write(to: imageURL!, options: NSData.WritingOptions.atomic)
                    }catch let error as NSError {
                        let _ = displayError(title: "Failed to save icon file(s)", text: error.localizedDescription)
                        
                    }

                } else {
                    return false
                }
                
            }

        }else{
            return false
        }
        return true
    }

    func resizeImage(image: NSImage, targetSize: CGSize) -> NSImage {
        let size = image.size

        let widthRatio = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)

        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff

        let newImage = NSImage.init(size: newSize)
        newImage.lockFocus()
        image.draw(in: rect)
        newImage.unlockFocus()
        return newImage
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

    func setOrigin(origin: String) {
        self.originLabel?.stringValue = "Origin: " + origin
    }
    func setLabel(label: String) {
        self.labelLabel?.stringValue = "Label: " + label
    }
    func setCodename(codename: String) {
        self.codenameLabel?.stringValue = "Codename: " + codename
    }
    func setDescription(description: String) {
        self.descriptionLabel?.stringValue = "Description: " + description
    }



    override func viewDidAppear() {
        mainPane = self.parent?.childViewControllers[0] as? RepositoryManagement
    }
    @IBAction func dismissParent(sender: NSButton) {
        self.parent?.dismiss(sender)
    }
}
