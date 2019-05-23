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
            lintQueue.cancelAllOperations()
        }
    }
    
    private var logViewController: LogViewController!
    private var statusViewController: StatusViewController!
    private var inspectorViewController: InspectorViewController!
    
    private var fileURL: URL? { return self.document?.fileURL }
    private var filename: String? { return self.fileURL?.lastPathComponent }
    private var workDirectory: String? { return self.fileURL?.deletingLastPathComponent().path }
    
    let lintQueue = OperationQueue()
    let compileQueue = OperationQueue()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shouldCascadeWindows = true
    }

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
        guard let document = document as? Document
        else { return assertionFailure() }
        
        // 2. If document is draft (fileURL = nil), save document first
        guard let workDirectory = self.workDirectory,
            let filename = self.filename else {
            document.saveAs(nil)
            return
        }
        
        // 2. Show progress indicator
        inspectorViewController.progressIndicator.isHidden = false
        inspectorViewController.progressIndicator.startAnimation(self)
        
        // 3. Save document and reset buildphases
        document.save(self)
        document.buildPhases = [BuildPhase]()

        // 6. Create and queue compile operations
        let compileOperations = ShellOperation.build(workDirectory: workDirectory, arguments: self.inspectorViewController.arguments, sourceFilename: filename)
        
        for operation in compileOperations {
            operation.delegate = self
            operation.completionBlock = {
                let buildPhase = BuildPhase(phase: operation.buildPhaseType, workDirectory: workDirectory, elapsedTime: operation.executionTime , errorMessage: operation.exitStatus == 0 ? nil : "Error")
                document.buildPhases!.append(buildPhase)
            }
        }
        compileQueue.addOperations(compileOperations, waitUntilFinished: false)
        
    }
    
    @IBAction func stop(_ sender: Any?) {
        print("Not implemented")
    }
}

// Docker delegate
extension EditorWindowController: ShellProtocol {
    func shell(_ docker: ShellOperation, didReceiveStdout string: String) {
        self.logViewController.stdout(string)
    }
    
    func shell(_ docker: ShellOperation, didReceiveStderr string: String) {
        
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
    
    func shell(_ docker: ShellOperation, didReceiveStdin string: String) {
        self.logViewController.stdin(string)
    }
    
}
