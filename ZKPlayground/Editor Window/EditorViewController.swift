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
            
//            let matches = regex.matches(in: lint.output, options: [], range: NSRange(location: 0, length: lint.output.count))
            let string =
"""
Compiling /home/zokrates/playground/root.code

Compilation failed:

 /home/zokrates/playground:4:3
    Expected one of [`def`], got `d`

 /home/zokrates/playground:5:12
    Another error message
"""
            let matches = regex.matches(in: string, options: [], range: string.fullRange)
            
            var compilerErrors = [CompilerError]()
            
            for match in matches {
                
                guard match.numberOfRanges >= 3 else { continue }
                
                guard let linenumberString = string.substring(with: match.range(at: 0)),
                    let columnString = string.substring(with: match.range(at: 1)),
                let message = string.substring(with: match.range(at: 2)) else {
                    continue
                }
                
                print("line number \(linenumberString)")
                print("column \(columnString)")
                print("message \(message)")
                
//                compilerErrors.append(CompilerError(type: .error, line: linenumber, column: column, message: message))
            }
            
            // For now, just fetch first error
            print("\(matches.count) matches")
            print("\(matches[0].numberOfRanges) ranges")
//            let range1 = matches[0]
//            guard matches.count >= 3 else { return }
        
//            print("linenumber: \(matches[0])")
//            print("character: \(matches[1])")
//            print("message: \(matches[2])")
        
            
//            print(matches)
//            print(lint.output)
            // Parse output...
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
