//
//  InspectorViewController.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/21/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class InspectorViewController: NSViewController {
    
    @IBOutlet weak var argumentsStackView: NSStackView!
    
//    let compileQueue = OperationQueue()
    
    override var representedObject: Any? {
        didSet {
            
            guard let document = representedObject as? Document, document.fileURL != nil else {
//                self.compileButton.isEnabled = false
                return
            }
            
//            self.compileButton.isEnabled = true
            
            // KVO arguments
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
