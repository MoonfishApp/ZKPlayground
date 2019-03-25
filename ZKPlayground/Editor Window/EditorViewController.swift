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

    let lexer = SokratesLexer()
    
    let lintQueue = OperationQueue()
    
    @IBOutlet weak var syntaxTextView: SyntaxTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        syntaxTextView.theme = DefaultSourceCodeTheme()
        syntaxTextView.delegate = self
        syntaxTextView.contentTextView.insertionPointColor = NSColor.white
    }
    
    @objc fileprivate func lint(_ sender: Any?) {
        
        guard let document  = representedObject as? Document,
            let filename = document.fileURL?.lastPathComponent,
            let workDirectory = document.fileURL?.deletingLastPathComponent().path
        else { return }
        
        document.save(nil)
        
        let lint = Lint(workDirectory: workDirectory, filename: filename)
        lint.completionBlock = {
            
            guard lint.output.contains("Compilation failed:"),
                let regex = try? NSRegularExpression(pattern: "(\\d+):(\\d+)[\\n\\r\\s]+(.*)", options: [])
            else { return }
            
            let matches = regex.matches(in: lint.output, options: [], range: lint.output.fullRange)
            
            var compilerErrors = [CompilerError]()
            
            for match in matches {
                
                guard match.numberOfRanges >= 4 else { continue }
                
                guard let linenumber = Int(String(lint.output.substring(with: match.range(at: 1)) ?? "")),
                    let column = Int(String(lint.output.substring(with: match.range(at: 2)) ?? "")),
                    let message = lint.output.substring(with: match.range(at: 3)) else {
                    continue
                }
                
                let compilerError = CompilerError(type: .error, line: linenumber, column: column, message: String(message))
                compilerErrors.append(compilerError)
                print(compilerError)
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
        perform(#selector(lint), with: nil, afterDelay: 2)
    }
    
    func didChangeSelectedRange(_ syntaxTextView: SyntaxTextView, selectedRange: NSRange) {
        
        
    }
    
    func lexerForSource(_ source: String) -> Lexer {
        return lexer
    }
    
}
