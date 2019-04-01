//
//  BuildPhase.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/31/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

enum BuildPhase {
    case compile(TimeInterval), setup(TimeInterval), witness(TimeInterval), proof(TimeInterval), verifier(TimeInterval)
    
    var filenames: [String] {
        switch self {
        case .compile:
            return ["out", "out.code"]
        case .setup:
            return ["proving.key", "variables.inf", "verification.key"]
        case .witness:
            return ["witness"]
        case .proof:
            return ["proof.json"]
        case .verifier:
            return ["verifier.sol"]
        }
    }
    
    func urls(baseDirectory: String) -> [URL] {
        return [URL]()
    }
    
    var action: String? {
        return nil
    }
}

