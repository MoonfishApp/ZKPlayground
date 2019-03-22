//
//  LogViewController.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/20/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa

class LogViewController: NSViewController {

    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func stdin(_ string: String) {
        
        output("$ " + string, color: NSColor.green)
    }
    
    func stdout(_ string: String) {
        
        output(string, color: NSColor.darkGray)        
    }
    
    func stderr(_ string: String) {
        
        output(string, color: NSColor.red)
    }
    
    private func output(_ string: String, color: NSColor) {
        
        DispatchQueue.main.async {
            let attributed = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: NSFont(name: "menlo", size: NSFont.systemFontSize)!])
            self.textView.textStorage?.append(attributed)
            self.textView.isEditable = true
            self.textView.checkTextInDocument(nil)
            self.textView.isEditable = false
            self.textView.scrollToEndOfDocument(nil)
        }
    }
    
}
