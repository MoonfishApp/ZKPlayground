//
//  AppDelegate.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/20/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        dockerInstall()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    private func dockerInstall() {
        
        if FileManager.default.fileExists(atPath: "//usr//local//bin//dockerl")  { return }
        
        let alert = NSAlert()
        alert.messageText = "Docker is not installed"
        alert.informativeText = "ZK Playground requires Docker"
        alert.addButton(withTitle: "Download Docker")
        alert.addButton(withTitle: "Continue anyway")
        let response = alert.runModal()
        if response == .alertFirstButtonReturn,
            let url = URL(string: "https://docs.docker.com/docker-for-mac/install") {
            NSWorkspace.shared.open(url)
        }
    }
    
}

