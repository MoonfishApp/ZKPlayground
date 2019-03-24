//
//  InspectorViewController.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/21/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class InspectorViewController: NSViewController {
    
    @IBOutlet weak var compileButton: NSButton!
    @IBOutlet weak var textField: NSTextField!
    
    let compileQueue = OperationQueue()
    
    override var representedObject: Any? {
        didSet {
            guard let document = representedObject as? Document, document.fileURL != nil else {
                self.compileButton.isEnabled = false
                return
            }
            
            self.compileButton.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func buttonPushed(_ sender: Any) {
        
        let controller = self.view.window!.windowController! as! EditorWindowController
        guard let operation = controller.lintQueue.operations.first as? Docker else {
            return assertionFailure()
        }
        
        operation.lint()
//        operation.write(self.textField.stringValue)
    }
    
}
