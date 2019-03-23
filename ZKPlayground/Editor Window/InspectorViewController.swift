//
//  InspectorViewController.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/21/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class InspectorViewController: NSViewController {
    
    @IBOutlet weak var textField: NSTextField!
    
    override var representedObject: Any? {
        didSet {
//            guard let document = representedObject as? Document else { return }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    @IBAction func buttonPushed(_ sender: Any) {
        
        let controller = self.view.window!.windowController! as! EditorWindowController
        guard let operation = controller.dockerQueue.operations.first as? Docker else {
            return assertionFailure()
        }
        
        operation.compile()
//        operation.write(self.textField.stringValue)
    }
    
}
