//
//  CompilerError.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/24/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

enum CompilerErrorType {
    case error, warning
}

struct CompilerError {
    
    let type: CompilerErrorType
    
    let line: Int
    
    let column: Int
    
    let message: String    
}

extension CompilerError {
    
    static func createErrors(string: String) -> [CompilerError] {
        
        var errors = [CompilerError]()
        let regex = try! NSRegularExpression(pattern: "(\\d+):(\\d+)[\\n\\r\\s]+(.*)", options: [])
        
        let matches = regex.matches(in: string, options: [], range: string.fullRange)
        
        for match in matches {
            
            guard match.numberOfRanges >= 4 else { continue }
            
            guard let linenumber = Int(String(string.substring(with: match.range(at: 1)) ?? "")),
                let column = Int(String(string.substring(with: match.range(at: 2)) ?? "")),
                let message = string.substring(with: match.range(at: 3)) else {
                    continue
            }
            
            errors.append(CompilerError(type: .error, line: linenumber, column: column, message: String(message)))
        }
        return errors
    }
}
