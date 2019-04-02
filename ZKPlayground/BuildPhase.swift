//
//  BuildPhase.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/31/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

class BuildPhase: NSObject {
    
    let phase: BuildPhaseType
    
    var name: String {
        return phase.rawValue
    }
    
    let errorMessage: String?
    
    let elapsedTime: TimeInterval?
    
    init(phase: BuildPhaseType, elapsedTime: TimeInterval? = nil, errorMessage: String? = nil) {
        
        self.phase = phase
        self.elapsedTime = elapsedTime
        self.errorMessage = errorMessage
        
        super.init()
    }
    
    func urls(baseDirectory: String) -> [URL] {
        return [URL]()
    }
    
    var action: String? {
        return nil
    }
    
}

enum BuildPhaseType: String {
    
    case compile, setup, witness, proof, verifier
    
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
}

