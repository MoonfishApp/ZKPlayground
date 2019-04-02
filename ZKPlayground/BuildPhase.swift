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
        return phase.rawValue.prefix(1).capitalized + phase.rawValue.dropFirst()
    }
    
    let urls: [String]?
    
    let successful: Bool
    
    let errorMessage: String?
    
    let elapsedTime: TimeInterval?
    
    init(phase: BuildPhaseType, workDirectory: String, elapsedTime: TimeInterval? = nil, errorMessage: String? = nil) {
        
        self.phase = phase
        self.elapsedTime = elapsedTime
        self.errorMessage = errorMessage
        
        self.urls = phase.filenames.map{
            return URL(fileURLWithPath: workDirectory).appendingPathComponent(Docker.buildDirectory).appendingPathComponent($0).path
        }
        if let urls = self.urls { self.successful = urls.filter{ FileManager.default.fileExists(atPath: $0) }.count == urls.count
        } else { self.successful = false }
        
        super.init()
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

