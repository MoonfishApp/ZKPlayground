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
        
        verifyZokratesInstall()
        
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
    
    private func verifyZokratesInstall() {
        
        let zokratesPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".zokrates/bin/zokrates").path
        
        print(zokratesPath)
        
        if FileManager.default.isExecutableFile(atPath: zokratesPath)  { return }
        
        // Zokrates is not installed
        let alert = NSAlert()
        alert.messageText = "Zokrates is not installed"
        alert.informativeText = "run 'curl -LSfs get.zokrat.es | sh' in the terminal to install Zokrates"
        alert.runModal()
    }
    
    @IBAction func showTemplates(_ sender: AnyObject?) {
        
        let templateWindowController = NSStoryboard(name: NSStoryboard.Name("Templates"), bundle: nil).instantiateInitialController() as! NSWindowController
        templateWindowController.showWindow(sender)
    }
    
}

