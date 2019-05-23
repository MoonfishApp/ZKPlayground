//
//  Docker.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/21/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation
import Cocoa

protocol ShellProtocol: class {
    
    // Received data from shell
    func shell(_ shell: ShellOperation, didReceiveStdout string: String)
    
    // Received error from shell
    func shell(_ shell: ShellOperation, didReceiveStderr string: String)
    
    // App sent stdin to shell
    func shell(_ shell: ShellOperation, didReceiveStdin string: String)
}

class ShellOperation: Operation {
    
    weak var delegate: ShellProtocol?
    
    /// If any of the commands in the script returns non-zero,
    /// the script will cancel and forward the exit code
    /// 0 is success, anything else is an error
    /// http://www.tldp.org/LDP/abs/html/exitcodes.html
    private (set) var exitStatus: Int?
    
    private (set) var executionTime: TimeInterval?
    
    // If true, output will be stored in output property
    private let logOutput: Bool
    
    private (set) var output = ""
    let buildPhaseType: BuildPhaseType
    
    
    fileprivate let task = Process()
    
    private let stdoutPipe = Pipe()
    private let stderrPipe = Pipe()
    private let stdinPipe = Pipe()
    private var notifications = [NSObjectProtocol]()
    
    fileprivate let workDirectory: String
    var buildDirectory: String { return URL(fileURLWithPath: self.workDirectory).appendingPathComponent("build").path }
    
    init(workDirectory: String, buildPhase: BuildPhaseType, logOutput: Bool = true) {
        
        self.workDirectory = workDirectory
        self.buildPhaseType = buildPhase
        self.logOutput = logOutput
        
        super.init()
    }
    
    /// Runs Zokrates
    override func main() {
            
        guard isCancelled == false else { return }
        
        let startTime = DispatchTime.now()
        
        // Create build directory
        if self.createBuildDirectory() == false {
            assertionFailure()
            return
        }
        
        // Set up task

        // Exporting Zokrates paths in environment. May not be necessary
        let zokratesDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".zokrates")
        let zokratesBinPath = zokratesDirectory.appendingPathComponent("bin").path
        
        // Set executable to Zokrates
        self.task.executableURL = URL(fileURLWithPath: zokratesBinPath, isDirectory: true).appendingPathComponent("zokrates")
        
        // currentDirectoryPath is the starting point for any relative path speficied.
        // Set to the buildDirectory.
        self.task.currentDirectoryPath = self.buildDirectory
        
        if self.logOutput {
            
            // Print to log
            let path = task.currentDirectoryPath
            let command: String = task.executableURL?.path ?? ""
            let arguments: String = task.arguments?.joined(separator: " ") ?? ""
            self.delegate?.shell(self, didReceiveStdin: "\n\(path)$ " + command + " " + arguments + "\n")
            print("\n\(path)$ " + command + " " + arguments + "\n")
        }
        
        // Set exitStatus at exit
        self.task.terminationHandler = { task in
            self.exitStatus = Int(task.terminationStatus)
            if self.exitStatus == 0 {
                self.delegate?.shell(self, didReceiveStdout: "\nTask exited with exit status 0\n")
            } else {
                self.delegate?.shell(self, didReceiveStderr: "\nTask exited with exit status \(self.exitStatus!)\n")
            }
            _ = self.notifications.map { NotificationCenter.default.removeObserver($0) }
        }
        
        // Handle I/O
        self.task.standardOutput = self.stdoutPipe
        self.task.standardError = self.stderrPipe
        self.task.standardInput = self.stdinPipe

        self.capture(self.stdoutPipe) { stdout in
            
            self.delegate?.shell(self, didReceiveStdout: stdout)
            if self.logOutput == true {
                self.output += stdout
                print(stdout)
            }
            
            // uncomment to print utf8 values
//            var s = ""
//            _ = stdout.utf8.map{ s.append("\($0), ") }
//            self.delegate?.shell(self, didReceiveStdin: s)
        }
        
        self.capture(self.stderrPipe) { stderr in
            
            self.delegate?.shell(self, didReceiveStderr: stderr)
            if self.logOutput == true {
                self.output += stderr
                print(stderr)
            }
        }
        
        task.launch()
        self.task.waitUntilExit() // uncomment when testing Hello-world
        let endTime = DispatchTime.now()
        self.executionTime = TimeInterval(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds)
    }
    
    private func capture(_ pipe: Pipe, dataReceived: @escaping (String) -> Void) {
        
        let notification = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: pipe.fileHandleForReading , queue: nil) { notification in
            
            let output = pipe.fileHandleForReading.availableData
            
            guard let outputString = String(data: output, encoding: String.Encoding.utf8), !outputString.isEmpty else { return }
            
            dataReceived(outputString)
            
            pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
        
        notifications.append(notification)
            
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
    }
    
    /// Will add newline character to string
    ///
    /// - Parameter string: <#string description#>
    func write(_ string: String, wait: Bool = true) {
        
        let string = string + "\n"
        guard task.isRunning == true, let data = (string).data(using: .utf8) else { return assertionFailure() }
        self.delegate?.shell(self, didReceiveStdin: "\n" + string)
        self.stdinPipe.fileHandleForWriting.write(data)
        if wait == true { self.stdinPipe.fileHandleForWriting.waitForDataInBackgroundAndNotify() }
    }
    
    override func cancel() {
        
        if task.isRunning { task.interrupt() }
        self.stdinPipe.fileHandleForReading.closeFile()
        self.stderrPipe.fileHandleForReading.closeFile()
        self.stdoutPipe.fileHandleForWriting.closeFile()
        super.cancel()
    }
    
    fileprivate func createBuildDirectory() -> Bool {
        
        // 1. Check if build directory exists
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        if manager.fileExists(atPath: self.buildDirectory, isDirectory: &isDirectory) == false || isDirectory.boolValue == false {
            
            // Build directory does not exist. Create it
            do {
                try
                    manager.createDirectory(atPath: self.buildDirectory, withIntermediateDirectories: false, attributes: nil)
            } catch {
                NSAlert(error: error).runModal()
                return false
            }
        }
        
        // 2. Delete all files in the build directory
        let enumerator = manager.enumerator(at: URL(fileURLWithPath: self.buildDirectory, isDirectory: true), includingPropertiesForKeys: nil)
        while let file = enumerator?.nextObject() as? URL {
            do {
                try manager.removeItem(at: file)
            } catch {
                NSAlert(error: error).runModal()
                return false
            }
        }
        
        return true
    }
}

// Convenience inits
extension ShellOperation {
    
    private static func assemble(arguments: [String], workDirectory: String, buildPhase: BuildPhaseType, logOutput: Bool = true) -> ShellOperation {
        
        let operation = ShellOperation(workDirectory: workDirectory, buildPhase: buildPhase, logOutput: logOutput)
        operation.task.arguments = arguments
        return operation
    }
    
    /// Compiles code, returns warnings and errors
    static func lint(workDirectory: String, sourceFilename: String, logOutput: Bool = false) -> ShellOperation {
        
        // TODO: don't delete the other files in the build directory
        
        return assemble(arguments: ["compile", "-i", "../" + sourceFilename], workDirectory: workDirectory, buildPhase: .compile, logOutput: logOutput)
    }
    
    static func build(workDirectory: String, arguments: [String]?, sourceFilename: String, logOutput: Bool = true) -> [ShellOperation] {
        
        let compileOperation = compile(workDirectory: workDirectory, sourceFilename: sourceFilename, logOutput: logOutput)
        let witnessOperation = witness(arguments: arguments, workDirectory: workDirectory, logOutput: logOutput)
        let setupOperation = setup(workDirectory: workDirectory, logOutput: logOutput)
        let verifierOperation = verifier(workDirectory: workDirectory, logOutput: logOutput)
        let proofOperation = proof(workDirectory: workDirectory, logOutput: logOutput)
        
        // Add dependencies, so operations are executed in the right order
        proofOperation.addDependency(verifierOperation)
        verifierOperation.addDependency(setupOperation)
        setupOperation.addDependency(witnessOperation)
        witnessOperation.addDependency(compileOperation)
        
        return [compileOperation, witnessOperation, setupOperation, verifierOperation, proofOperation]
    }
    
    /// Compiles code
    static func compile(workDirectory: String, sourceFilename: String, logOutput: Bool = true) -> ShellOperation {
        
        // TODO: don't delete the other files in the build directory
        
        return assemble(arguments: ["compile", "-i", "../" + sourceFilename], workDirectory: workDirectory, buildPhase: .compile, logOutput: logOutput)
    }
    
    /// Computes a witness for the compiled program found at ./out.code and arguments to the program.
    static func witness(arguments: [String]? = nil, workDirectory: String, logOutput: Bool = true) -> ShellOperation {
        
        var args = ["compute-witness"]
        if let arguments = arguments {
            args.append("-a")
            args.append(contentsOf: arguments)
        }
        
        return assemble(arguments: args, workDirectory: workDirectory, buildPhase: .witness, logOutput: logOutput)
    }
    
    /// Generates a trusted setup for the compiled program found at ./out.code
    /// Creates a proving key and a verifying key at ./proving.key and ./verifying.key. These keys are derived from a source of randomness, commonly referred to as “toxic waste”. Anyone having access to the source of randomness can produce fake proofs that will be accepted by a verifier following the protocol.
    static func setup(workDirectory: String, logOutput: Bool = true) -> ShellOperation {
        
        return assemble(arguments: ["setup"], workDirectory: workDirectory, buildPhase: .setup, logOutput: logOutput)
    }
    
    /// Using the verifying key at ./verifying.key, generates a Solidity contract which contains the generated verification key and a public function to verify a solution to the compiled program at ./out.code.
    /// Creates a verifier contract at ./verifier.sol.
    static func verifier(workDirectory: String, logOutput: Bool = true) -> ShellOperation {
        
        return assemble(arguments: ["export-verifier"], workDirectory: workDirectory, buildPhase: .verifier, logOutput: logOutput)
    }

    /// Using the proving key at ./proving.key, generates a proof for a computation of the compiled program ./out.code resulting in ./witness.
    static func proof(workDirectory: String, logOutput: Bool = true) -> ShellOperation {
        
        return assemble(arguments: ["generate-proof"], workDirectory: workDirectory, buildPhase: .proof, logOutput: logOutput)
    }
}
