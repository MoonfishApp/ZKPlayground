//
//  String.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/24/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

extension String {
    
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
    
    var fullRange: NSRange {
        return NSRange(location: 0, length: self.count)
    }
    
}
