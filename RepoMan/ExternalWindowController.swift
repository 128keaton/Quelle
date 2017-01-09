//
//  ExternalWindowController.swift
//  Quelle
//
//  Created by Keaton Burleson on 1/8/17.
//  Copyright © 2017 Keaton Burleson. All rights reserved.
//
import Cocoa
import Foundation
class External: NSWindowController{
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.backgroundColor = NSColor.white
        self.window?.contentViewController?.view.layer?.backgroundColor = NSColor.white.cgColor
    }
}
