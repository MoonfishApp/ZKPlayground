//
//  BuildPhaseStackView.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 4/1/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class BuildPhaseStackView: NSStackView {
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var errorMessageTextField: NSTextField!
    @IBOutlet weak var viewInFinderButton: NSButton!
}
