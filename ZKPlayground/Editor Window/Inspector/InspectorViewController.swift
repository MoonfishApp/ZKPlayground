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
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override var representedObject: Any? {
        didSet {
            
            guard let representedObject = representedObject as? Document else { return }

            self.argumentObserver = representedObject.observe(\Document.arguments, options: [.new, .initial]) { queue, change in
                
                self.addArgumentViews()
            }
            
            self.buildPhaseObserver = representedObject.observe(\Document.buildPhases, options: [.new, .initial]) { queue, change in
                
                self.addBuildPhaseViews()
            }
        }
    }
    
    /// EditorWindowController fetches the arguments here when compile button is pressed
    var arguments: [String] {
                
        return self.argumentsStackView.subviews.filter({ $0 is ArgumentStackView }).map({ ($0 as! ArgumentStackView).textField.stringValue })
    }
    
    private var argumentObserver: NSKeyValueObservation?
    private var buildPhaseObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func addArgumentViews() {
        
        // 1. Store old arguments
        var oldValues = [String]()
        
        // 2. Remove argument views
        _ = self.argumentsStackView.subviews.filter({ $0 is ArgumentStackView }).enumerated().map({ (index, view) in
            
            // 2a. Store old value
            oldValues.append((view as! ArgumentStackView).textField.stringValue)
            
            // 2b. Remove views
            self.argumentsStackView.removeView(view)
            view.isHidden = true
        })
        
        // 3. Sanity check
        guard let document = representedObject as? Document, let arguments = document.arguments else {
            return
        }
        
        // 4. Add argument views
        for (index, argument) in arguments.enumerated() {

            // 3a. Load view from NIB
            var topLevelObjects: NSArray?
            Bundle.main.loadNibNamed("ArgumentView", owner: self, topLevelObjects: &topLevelObjects)
            let argumentView = topLevelObjects?.first(where: { $0 is NSView } ) as! ArgumentStackView
            
            // 3b. Set label
            argumentView.label.stringValue = (argument.isPrivate ? "private " : "") + argument.name
            
            // 3c. Set old values, if present
            if oldValues.count > index {
                argumentView.textField.stringValue = oldValues[index]
            }
            
            // 3d. Add view to stackview
            self.argumentsStackView.insertView(argumentView, at: index, in: .top)
            argumentView.leadingAnchor.constraint(equalTo: self.argumentsStackView.leadingAnchor).isActive = true
            argumentView.trailingAnchor.constraint(equalTo: self.argumentsStackView.trailingAnchor).isActive = true
        }
    }
    
    func addBuildPhaseViews() {
        
        DispatchQueue.main.async {
     
            // 1. Remove build phase views
            _ = self.argumentsStackView.subviews.filter({ $0 is BuildPhaseStackView }).map({
                self.argumentsStackView.removeView($0)
                $0.isHidden = true
            })
            
            // 2. Sanity check
            guard let document = self.representedObject as? Document, let phases = document.buildPhases else {
                return
            }
            
            // 3. Add arguement views
            for (index, phase) in phases.enumerated() {
                
                // 3a. Load view from NIB
                var topLevelObjects: NSArray?
                Bundle.main.loadNibNamed("BuildPhaseView", owner: self, topLevelObjects: &topLevelObjects)
                let buildPhaseView = topLevelObjects?.first(where: { $0 is NSView } ) as! BuildPhaseStackView
                
                // 3b. Set labels
                buildPhaseView.viewInFinderButton.tag = index
                if phase.successful {
                    
                    // Phase was successful
                    buildPhaseView.titleLabel.stringValue = "✅ " + phase.name
                    buildPhaseView.timeLabel.stringValue = phase.elapsedTime == nil ? " " : "\(phase.elapsedTime!)s"
                    if let result = phase.fetchCompilerResult() {
                        buildPhaseView.textField.stringValue = result
                        buildPhaseView.textField.isHidden = false
                    } else {
                        buildPhaseView.textField.isHidden = true
                    }
                    
                } else {
                    
                    // Phase was unsuccessful
                    
                    buildPhaseView.titleLabel.stringValue = "🛑 " + phase.name
                    buildPhaseView.viewInFinderButton.isHidden = true
                    buildPhaseView.timeLabel.isHidden = true
                    
                    if let errorMessage = phase.errorMessage {
                        buildPhaseView.textField.stringValue = errorMessage
                        buildPhaseView.textField.textColor = .red
                    } else {
                        buildPhaseView.textField.isHidden = true
                    }
                }
                
                // 3c. Add view to stackview
                self.argumentsStackView.addView(buildPhaseView, in: .top)
                buildPhaseView.leadingAnchor.constraint(equalTo: self.argumentsStackView.leadingAnchor).isActive = true
                buildPhaseView.trailingAnchor.constraint(equalTo: self.argumentsStackView.trailingAnchor).isActive = true
            }
            self.progressIndicator.stopAnimation(self)
        }
    }
    
    @IBAction func showFilesInFinder(_ sender: Any?) {
    
        guard let document = self.representedObject as? Document,
            let phases = document.buildPhases,
            let sender = sender as? NSButton,
            phases.count > sender.tag,
            let urls = phases[sender.tag].urls else {
            return assertionFailure()
        }
        
        NSWorkspace.shared.activateFileViewerSelecting(urls.map{ return URL(fileURLWithPath: $0) })
    }
}
