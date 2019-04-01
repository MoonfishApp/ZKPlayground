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
    
    override var representedObject: Any? {
        didSet {
            
            guard let representedObject = representedObject as? Document else {
                return
            }

            self.argumentObserver = representedObject.observe(\Document.arguments, options: [.new, .initial]) { queue, change in
                self.addArgumentViews()
            }
        }
    }
    
    var arguments: [String] {
                
        return self.argumentsStackView.subviews.filter({ $0 is ArgumentStackView }).map({ ($0 as! ArgumentStackView).textField.stringValue })
    }
    
    private var argumentObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func addArgumentViews() {
        
        // Remove argument views
        _ = self.argumentsStackView.subviews.filter({ $0 is ArgumentStackView }).map({
            self.argumentsStackView.removeView($0)
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
            argumentView.label.stringValue = (argument.isPrivate ? "private " : "") + argument.name + (argument.isPrivate ? "🕶" : "")
            print(argumentView.label.stringValue)
            self.argumentsStackView.insertView(argumentView, at: index, in: .top)
            
            if index == 0 {
                argumentView.textField.stringValue = "337"
            } else if index == 1 {
                argumentView.textField.stringValue = "113569"
            }
        }
    }
    
}
