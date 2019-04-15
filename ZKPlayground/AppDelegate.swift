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
        
        dockerInstall()
        
        // If no document is restored, show template chooser
//        if NSDocumentController.shared.documents.isEmpty {
//            showTemplates(nil)
//        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // Prevent showing empty untitled project window at startup
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }

    private func dockerInstall() {
        
        if FileManager.default.isExecutableFile(atPath: "//usr//local//bin//docker")  { return }
        
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
    
    @IBAction func showTemplates(_ sender: AnyObject?) {
        
        let templateWindowController = NSStoryboard(name: NSStoryboard.Name("Templates"), bundle: nil).instantiateInitialController() as! NSWindowController
        templateWindowController.showWindow(sender)
    }
    
}

