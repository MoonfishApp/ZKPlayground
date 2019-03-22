//
//  EditorWindowController.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/21/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class EditorWindowController: NSWindowController {
    
    override var document: AnyObject? {
        didSet {
            
            contentViewController?.representedObject = document
            
            guard let document = document as? Document, document.fileURL != self.fileURL else { return }
            
            self.fileURL = document.fileURL
            dockerQueue.cancelAllOperations()
            
            guard self.fileURL != nil else { return }
            
            // (Re)launch Docker
            self.runDocker(nil)
            
            // TODO: KVO to check if file location has changed?
        }
    }
    
    private var logViewController: LogViewController!
    private var statusViewController: StatusViewController!
    
    private var fileURL: URL?
    private var filename: String? { return self.fileURL?.lastPathComponent }
    private var workDirectory: String? { return self.fileURL?.deletingLastPathComponent().path }
    
    let dockerQueue = OperationQueue()

    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        self.logViewController = ((contentViewController as! NSSplitViewController).splitViewItems[2].viewController as! LogViewController)
        self.statusViewController = ((contentViewController as! NSSplitViewController).splitViewItems[1].viewController as! StatusViewController)
    }

}

// Docker extensions
extension EditorWindowController {
    
    @IBAction func runDocker(_ sender: Any?) {
        
        guard let filename = self.filename, let workDirectory = self.workDirectory else { return }
        
        let docker = Docker(workDirectory: workDirectory, filename: filename)
        docker.delegate = self
        
        // Start docker
        dockerQueue.maxConcurrentOperationCount = 1
        dockerQueue.qualityOfService = .userInitiated
        dockerQueue.addOperation(docker)
    }
    
    @IBAction func stop(_ sender: Any?) {
        
    }
}

// Docker delegate
extension EditorWindowController: DockerProtocol {
    func docker(_ docker: Docker, didReceiveStdout string: String) {
        self.logViewController.stdout(string)
    }
    
    func docker(_ docker: Docker, didReceiveStderr string: String) {
        
        // Open log pane
        DispatchQueue.main.async {
            let item = (self.contentViewController as! NSSplitViewController).splitViewItems[2]
            
            if item.isCollapsed {
                self.statusViewController.disclosureClicked(self)
                self.statusViewController.disclosureButton.state = .on
            }
        }
        
        self.logViewController.stderr(string)
    }
    
    func docker(_ docker: Docker, didReceiveStdin string: String) {
        self.logViewController.stdin(string)
    }
    
}
