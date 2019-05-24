//
//  TimeInterval.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/31/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

extension TimeInterval {
    
    
    /// Creates array of TimeIntervals from string
    ///
    /// - Parameter string: Bash stdout
    /// Expected format:
    /// Bash time format set to: TIMEFORMAT='Elapsed time: %3R'
    /// Example: "Elapsed time: 0.003"
    /// - Returns: Array of timeintervals
/*    static func parse(_ string: String) -> [TimeInterval] {
        
        let regex = try! NSRegularExpression(pattern: "(?<=Elapsed time\\:\\s)[0-9]{1,2}+\\.[0-9]{1,3}", options: [])
        
        let matches = regex.matches(in: string, options: [], range: string.fullRange)
        
        return matches.compactMap{
            return TimeInterval(String(string.substring(with: $0.range(at: 0)) ?? "")) ?? nil
        }
    } */
}
