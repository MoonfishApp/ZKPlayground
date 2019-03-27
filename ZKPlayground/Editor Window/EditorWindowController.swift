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
            
            guard self.fileURL != nil else { return }
            
//            lint(self)
        }
    }
    
    private var logViewController: LogViewController!
    private var statusViewController: StatusViewController!
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
//        self.syntaxTextView = (((contentViewController as! NSSplitViewController).splitViewItems[0].viewController as! NSSplitViewController).splitViewItems[0].viewController as! EditorViewController).syntaxTextView
    }

}

// Docker extensions
extension EditorWindowController {
    
//    @IBAction func lint(_ sender: Any?) {
//
//        guard let filename = self.filename, let workDirectory = self.workDirectory else { return }
//
//        let lint = Lint(workDirectory: workDirectory, filename: filename)
//        lint.delegate = self
//        lint.completionBlock = {
//
//            self.syntaxTextView.highlight(line: 0, character: 1, color: .red, message: "test error message")
//            print(lint.output)
//        }
//        lintQueue.addOperation(lint)
//    }
    
    @IBAction func compile(_ sender: Any?) {
        
        (document as? Document)?.save(self)
        
        guard let filename = self.filename, let workDirectory = self.workDirectory else { return }

        let compile = Compile(workDirectory: workDirectory, filename: filename, arguments: ["337", "113569"])
        compile.delegate = self
        compile.completionBlock = {
//            print (compile.output)
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
