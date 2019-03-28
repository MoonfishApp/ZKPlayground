//
//  Argument.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/27/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

struct Argument {
    
    /// True if private is set
    let isPrivate: Bool
    
    /// E.g. field
    let type: String
    
    /// Name of the argument, e.g. 'a'
    let name: String
    
    // Full original string, for debugging purposes
    let originalString: String
}

extension Argument {
    /*
    static func createArguments(string: String) -> [Argument] {
        
        var arguments = [Argument]()
        
        let regex = try! NSRegularExpression(pattern: "def\\s+main[^(]*\\(([^)]*)\\)", options: [])
        let matches = regex.matches(in: string, options: [], range: string.fullRange)
        
        guard let subString = string.substring(with: matches[0].range(at: 1)) else { return arguments }
        
        let argumentsStrings = String(subString).components(separatedBy: ",")
        
        // remove traling and leading spaces
        _ = argumentsStrings.map {
            let argument = Argument(isPrivate: <#T##Bool#>, type: <#T##String#>, name: <#T##String#>, originalString: $0)
            
            
//            print($0.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }*/
}
