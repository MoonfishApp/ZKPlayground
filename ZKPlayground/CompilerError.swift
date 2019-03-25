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
