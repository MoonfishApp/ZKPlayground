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
        
        addArgumentViews()
    }
    
    func addArgumentViews() {
        
        
        guard let document = representedObject as? Document else {
//            argumentsStackView.removeArrangedSubview(<#T##view: NSView##NSView#>)
            return
        }
        
        var topLevelObjects: NSArray?
        Bundle.main.loadNibNamed("ArgumentView", owner: self, topLevelObjects: &topLevelObjects)
            
        let argumentView = topLevelObjects?.first(where: { $0 is NSView } ) as! ArgumentStackView
            

        print(argumentView)
        argumentsStackView.addArrangedSubview(argumentView)
//        argumentsStackView.addView(<#T##view: NSView##NSView#>, in: <#T##NSStackView.Gravity#>)
        
//        let subviews = (0..<3).map { (_) -> CustomView in
//            return UINib(nibName: "CustomView", bundle: nil).instantiateWithOwner(nil,
//                                                                                  options: nil)[0] as! CustomView
//        }
    }
    
}
