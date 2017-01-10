//
//  GlobalFunctions.swift
//  RepoMan
//
//  Created by Keaton Burleson on 1/2/17.
//  Copyright © 2017 Keaton Burleson. All rights reserved.
//

import Foundation
import Cocoa

// Global Functions :D

func displayError(title: String, text: String) -> Bool {
    let alert: NSAlert = NSAlert()
    alert.messageText = title
    alert.informativeText = text
    alert.alertStyle = NSAlertStyle.critical
    alert.addButton(withTitle: "OK")
    return alert.runModal() == NSAlertFirstButtonReturn
}

func displayMessage(title: String, text: String) {
    let alert: NSAlert = NSAlert()
    alert.messageText = title
    alert.informativeText = text
    alert.alertStyle = NSAlertStyle.informational
    alert.addButton(withTitle: "Yay")
    alert.runModal()

}

class VerticallyCenteredTextFieldCell : NSTextFieldCell {
    override func titleRect(forBounds rect: NSRect) -> NSRect {
        var titleRect = super.titleRect(forBounds: rect)
        
        let minimumHeight = self.cellSize(forBounds: rect).height
        titleRect.origin.y += (titleRect.height - minimumHeight) / 2
        titleRect.size.height = minimumHeight
        
        return titleRect
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.drawInterior(withFrame: titleRect(forBounds: cellFrame), in: controlView)
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    mutating func cleanPath(){
        self = self.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: NSHomeDirectory(), with: "~")
    }
}

// f the popo
class UIViewController: NSViewController{
    override func viewDidAppear() {
        if self.view.window != nil{
            self.view.window?.title = self.title!
        }
    }
}
