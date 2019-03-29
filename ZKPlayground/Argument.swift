//
//  Argument.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/27/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

class Argument: NSObject {
    
    /// True if private is set
    let isPrivate: Bool
    
    /// E.g. field
    let type: String
    
    /// Name of the argument, e.g. 'a'
    let name: String
    
    // Full original string, for debugging purposes
    let originalString: String
    
    init(isPrivate: Bool, type: String, name: String, originalString: String) {
        
        self.isPrivate = isPrivate
        self.type = type
        self.name = name
        self.originalString = originalString
        super.init()
    }
}

extension Argument {
    
    static func createArguments(string: String) -> [Argument] {
        
        var arguments = [Argument]()
        
        guard !string.isEmpty else { return arguments }
        
        let regex = try! NSRegularExpression(pattern: "def\\s+main[^(]*\\(([^)]*)\\)", options: [])
        let matches = regex.matches(in: string, options: [], range: string.fullRange)
        
        guard let subString = string.substring(with: matches[0].range(at: 1)) else { return arguments }
        
        let argumentsStrings = String(subString).components(separatedBy: ",")
        
        // remove traling and leading spaces
        _ = argumentsStrings.map {
            
            let argumentString = $0.trim()!
            let words = argumentString.components(separatedBy: .whitespaces)
            
            
            
            let isPrivate = (words.first ?? "" == "private")
            let name, type: String
            if isPrivate {
                // Minimum is "field name". If less than two, user is typing or source has syntax error
                guard words.count > 2 else { return }
                type = words[1].trim()!
                name = words[2].trim()!
            } else {
                guard words.count > 1 else { return }
                type = words[0].trim()!
                name = words[1].trim()!
            }
            
            let argument = Argument(isPrivate: isPrivate, type: type, name: name, originalString: argumentString)
            
            arguments.append(argument)
        }
        
        return arguments
    }
}

