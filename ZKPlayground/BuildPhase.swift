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
            URL(fileURLWithPath: workDirectory).appendingPathComponent("build").appendingPathComponent($0).path
        }
        if let urls = self.urls { self.successful = urls.filter{ FileManager.default.fileExists(atPath: $0) }.count == urls.count
        } else { self.successful = false }
        
        super.init()
    }
    
    var action: String? {
        return nil
    }
    
    func fetchCompilerResult() -> String? {
        
        // Check if files exist?
        print(self.phase.rawValue)
        
        guard let urls = self.urls else { assertionFailure(); return nil }
        
        // Lazy but working: Apply regex to all files in list
        return urls.compactMap({
            if FileManager.default.fileExists(atPath: $0) == false {
                print("\($0) does not exist")
                print("")
            }
            guard let content = try? String(contentsOf: URL(fileURLWithPath: $0)) else {
                return nil
            }
            return matchResult(content)
        }).reduce("", +)
    }
    
    private func matchResult(_ result: String) -> String {
        
        guard let regex = phase.fileRegex(),
            let match = regex.matches(in: result, options: [], range: result.fullRange).first,
            match.numberOfRanges >= 1,
            let subString = result.substring(with: match.range(at: 0))
            else { return "" }
        
        return String(subString)
    }
    
}

enum BuildPhaseType: String {
    
    case compile, setup, witness, proof, verifier
    
    var filenames: [String] {
        switch self {
        case .compile:
            return ["out", "out.code"]
        case .setup:
            return ["proving.key", "verification.key"] // "variables.inf"
        case .witness:
            return ["witness"]
        case .proof:
            return ["proof.json"]
        case .verifier:
            return ["verifier.sol"]
        }
    }
    
    func fileRegex() -> NSRegularExpression? {
        switch self {
        case .compile:
            return nil
        case .setup:
            return nil
        case .witness:
            return try! NSRegularExpression(pattern: "(?<=~out_0\\s)[0-9]{1,4}", options: [])
        case .proof:
            return nil
        case .verifier:
            return nil
        
        
        }
    }
}

