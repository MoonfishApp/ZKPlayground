//
//  EditorWindowController.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/21/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa
import SavannaKit
import SourceEditor

class EditorWindowController: NSWindowController {
    
    override var document: AnyObject? {
        didSet {
            
            contentViewController?.representedObject = document
            
            guard let document = document as? Document, document.fileURL != self.fileURL else { return }
            
            self.fileURL = document.fileURL
            lintQueue.cancelAllOperations()
        }
    }
    
    private var logViewController: LogViewController!
    private var statusViewController: StatusViewController!
    private var inspectorViewController: InspectorViewController!
//    private var syntaxTextView: SyntaxTextView!
    
    private var fileURL: URL?
    private var filename: String? { return self.fileURL?.lastPathComponent }
    private var workDirectory: String? { return self.fileURL?.deletingLastPathComponent().path }
    
    let lintQueue = OperationQueue()
    let compileQueue = OperationQueue()

    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        lintQueue.maxConcurrentOperationCount = 1
        lintQueue.qualityOfService = .userInitiated

        compileQueue.maxConcurrentOperationCount = 1
        compileQueue.qualityOfService = .userInitiated

        
        self.logViewController = ((contentViewController as! NSSplitViewController).splitViewItems[2].viewController as! LogViewController)
        self.statusViewController = ((contentViewController as! NSSplitViewController).splitViewItems[1].viewController as! StatusViewController)
        self.inspectorViewController = (((contentViewController as! NSSplitViewController).splitViewItems[0].viewController as! NSSplitViewController).splitViewItems[1].viewController as! InspectorViewController)
//        self.syntaxTextView = (((contentViewController as! NSSplitViewController).splitViewItems[0].viewController as! NSSplitViewController).splitViewItems[0].viewController as! EditorViewController).syntaxTextView
    }

}

// Docker extensions
extension EditorWindowController {
    
    @IBAction func compile(_ sender: Any?) {
        
        // 1. Sanity check
        guard let document = document as? Document,
            let workDirectory = self.workDirectory,
            let filename = self.filename
        else { return }
        
        // 2. Save document and reset buildphases
        document.save(self)
        document.buildPhases = nil
        
        // 3.  Delete all files in the build directory
        let fileManager = FileManager.default
        let url = URL(string: workDirectory)!.appendingPathComponent("build")
        let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil)
        while let file = enumerator?.nextObject() as? URL {
            do {
                try fileManager.removeItem(at: file)
            } catch {
                let alert = NSAlert(error: error)
                alert.runModal()
                return
            }
        }

        // 4. Create and queue compile operation
        let compile = Compile(workDirectory: workDirectory, filename: filename, arguments: self.inspectorViewController.arguments)
        compile.delegate = self
        compile.completionBlock = {
            
            // 4.a Fetch time measurements
            let times = TimeInterval.parse(compile.output)
            
            // 4.b Set BuildPhases
            if times.count == 5 {
                var phases = [BuildPhase]()
                for (index, time) in times.enumerated() {
                    if index == 0 { phases.append(.compile(time))
                    } else if index == 1 { phases.append(.setup(time))
                    } else if index == 2 { phases.append(.witness(time))
                    } else if index == 3 { phases.append(.proof(time))
                    } else if index == 4 { phases.append(.verifier(time))
                    }
                }
                document.buildPhases = phases
            }
        }
        compileQueue.addOperation(compile)
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
