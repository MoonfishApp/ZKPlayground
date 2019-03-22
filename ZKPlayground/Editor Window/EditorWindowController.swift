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
    
    private var fileURL: URL?
    private var filename: String? { return self.fileURL?.lastPathComponent }
    private var workDirectory: String? { return self.fileURL?.deletingLastPathComponent().path }
    
    let dockerQueue = OperationQueue()

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}

// Docker extensions
extension EditorWindowController {
    
    @IBAction func runDocker(_ sender: Any?) {
        
        print("Run docker called")
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
    func docker(_ docker: Docker, didReceiveStdout: String) {
        
    }
    
    func docker(_ docker: Docker, didReceiveStderr: String) {
        
    }
    
    func docker(_ docker: Docker, didReceiveStdin: String) {
        
    }
    
    
}
