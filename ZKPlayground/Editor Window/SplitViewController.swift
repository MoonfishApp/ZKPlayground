//
//  SplitViewController.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/21/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {
    
    override var representedObject: Any? {
        didSet {
            for item in splitViewItems {
                item.viewController.representedObject = representedObject
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
