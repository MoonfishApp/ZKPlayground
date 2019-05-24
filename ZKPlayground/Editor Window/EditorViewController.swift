//
//  EditorViewController.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/20/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Cocoa
import SourceEditor
import SavannaKit

class EditorViewController: NSViewController {
    
    override var representedObject: Any? {
        didSet {
            guard let document = representedObject as? Document else { return }
            
            syntaxTextView.text = document.string
        }
    }

    let lexer = ZokratesLexer()
    
    let lintQueue = OperationQueue()
    
    @IBOutlet weak var syntaxTextView: SyntaxTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        syntaxTextView.theme = DefaultSourceCodeTheme()
        syntaxTextView.delegate = self
        syntaxTextView.contentTextView.insertionPointColor = NSColor.white
        syntaxTextView.autocompleteWords = self.lexer.keywords
    }
    
    @objc fileprivate func lint(_ sender: Any?) {
        return // ***REMOVE
        guard let document  = representedObject as? Document,
            let filename = document.fileURL?.lastPathComponent,
            let workDirectory = document.fileURL?.deletingLastPathComponent().path
        else { return }
        
        document.save(nil)
        
        let lint = ShellOperation.lint(workDirectory: workDirectory, sourceFilename: filename, logOutput: .none)
        lint.completionBlock = {

            if lint.output.contains("Compilation failed:") {
                
                // Create errors and highlight the lines in the editor
                _ = CompilerError.createErrors(string: lint.output).map {
                    self.syntaxTextView.highlight(line: $0.line, column: $0.column, color: $0.type == .error ? .red : .yellow, message: $0.message)
                }
                
            } else {
                
                // Linting successful, show arguments in inspector
                DispatchQueue.main.sync {
                    document.arguments = Argument.createArguments(string: self.syntaxTextView.text)
                }
            }
        }
        lintQueue.addOperation(lint)
    }
}


extension EditorViewController: SyntaxTextViewDelegate {
    
    func didChangeText(_ syntaxTextView: SyntaxTextView) {
        
        (representedObject as? Document)?.string = syntaxTextView.text
        
        // Invoke lint after two second delay
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(lint), with: nil, afterDelay: 0.5)
    }
    
    func didChangeFont(_ font: Font) {
        syntaxTextView.theme = DefaultSourceCodeTheme(font: font)
    }
    
    func didChangeSelectedRange(_ syntaxTextView: SyntaxTextView, selectedRange: NSRange) {
        
        
    }
    
    func lexerForSource(_ source: String) -> Lexer {
        return lexer
    }
    
}
