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
            
            guard let representedObject = representedObject as? Document else {
                return
            }
            
            addArgumentViews()

//            self.argumentObserver = representedObject.observe(\Document.arguments, options: .new) { queue, change in
//                
//                self.addArgumentViews()
//            }

        }
    }
    
    private var argumentObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
//        addArgumentViews()
    }
    
    func addArgumentViews() {
        
        // Remove argument views
        print("removing argumentviews")
        _ = self.argumentsStackView.subviews.filter({ $0 is ArgumentStackView }).map({
            self.argumentsStackView.removeArrangedSubview($0)
            $0.isHidden = true
        })
        
        guard let document = representedObject as? Document, let arguments = document.arguments else {
            return
        }
        
        for (index, argument) in arguments.enumerated() {

            print("adding \(argument.name)")
            var topLevelObjects: NSArray?
            Bundle.main.loadNibNamed("ArgumentView", owner: self, topLevelObjects: &topLevelObjects)
            let argumentView = topLevelObjects?.first(where: { $0 is NSView } ) as! ArgumentStackView
            argumentView.label.stringValue = (argument.isPrivate ? "private " : "") + argument.name + (argument.isPrivate ? "🕶" : "👓")
            print(argumentView.label.stringValue)
            self.argumentsStackView.insertView(argumentView, at: index, in: .top)
        }
        
//        argumentsStackView.needsLayout = true
//        argumentsStackView.displayIfNeeded()
    }
    
}
