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
        document.buildPhases = nil
        
        // 4. Build directory
        let fileManager = FileManager.default
        let buildDirectory = URL(string: workDirectory)!.appendingPathComponent(Docker.buildDirectory)
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: buildDirectory.path, isDirectory: &isDirectory) == false || isDirectory.boolValue == false {
            
            // 5.a Build directory does not exist. Create it
            do {
                try fileManager.createDirectory(atPath: buildDirectory.path, withIntermediateDirectories: false, attributes: nil)
            } catch {
                NSAlert(error: error).beginSheetModal(for: self.window!)
                inspectorViewController.progressIndicator.stopAnimation(self)
                return
            }
        } else {
        
            // 5.b  Delete all files in the build directory
            let enumerator = fileManager.enumerator(at: buildDirectory, includingPropertiesForKeys: nil)
            while let file = enumerator?.nextObject() as? URL {
                do {
                    try fileManager.removeItem(at: file)
                } catch {
                    NSAlert(error: error).beginSheetModal(for: self.window!)
                    inspectorViewController.progressIndicator.stopAnimation(self)
                    return
                }
            }
        }

        // 6. Create and queue compile operation
        let compile = Compile(workDirectory: workDirectory, filename: filename, arguments: self.inspectorViewController.arguments)
        compile.delegate = self
        compile.completionBlock = {
            
            // 5.a Fetch time measurements
            let times = TimeInterval.parse(compile.output)
            
            // 5.b Set BuildPhases
            var phases = [BuildPhase]()
            for index in 0 ..< 5 {
                
                var phase: BuildPhaseType {
                    switch index {
                    case 0:
                        return .compile
                    case 1:
                        return .setup
                    case 2:
                        return .witness
                    case 3:
                        return .proof
                    case 4:
                        return .verifier
                    default:
                        assertionFailure()
                        return .verifier
                    }
                }
                
                let buildPhase: BuildPhase
                if times.count > index {
                    // Phase completed successfully
                    buildPhase = BuildPhase(phase: phase, workDirectory: workDirectory, elapsedTime: times[index])
                } else {
                    // Error
                    buildPhase = BuildPhase(phase: phase, workDirectory: workDirectory, elapsedTime: nil, errorMessage: "Error")
                }
                phases.append(buildPhase)
            }
                    
            document.buildPhases = phases
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
