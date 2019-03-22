//
//  StatusViewController.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/20/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class StatusViewController: NSViewController {

    @IBOutlet weak var disclosureButton: NSButton!
    @IBOutlet weak var statusLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func disclosureClicked(_ sender: Any) {
        
        guard let splitController = (parent as? NSSplitViewController), let splitItem = splitController.splitViewItems.last else { return }
        
        splitItem.collapseBehavior = .preferResizingSplitViewWithFixedSiblings
        splitController.toggleSidebar(nil)
    }
}

