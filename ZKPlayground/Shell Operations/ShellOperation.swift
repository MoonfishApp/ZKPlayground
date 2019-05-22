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
    
    // If true, output will be stored in output property
    private let logOutput: Bool
    
    private (set) var output = ""
    
    fileprivate let task = Process()
    
    private let stdoutPipe = Pipe()
    private let stderrPipe = Pipe()
    private let stdinPipe = Pipe()
    private var notifications = [NSObjectProtocol]()
    
    /// Name of the .code file, e.g. "HelloWorld.code"
    fileprivate let sourceFilename: String
    fileprivate let workDirectory: String
    var buildDirectory: String { return URL(fileURLWithPath: self.workDirectory).appendingPathComponent("build").path }
    
    init(workDirectory: String, sourceFilename: String, logOutput: Bool = true) {
        
        self.sourceFilename = sourceFilename
        self.workDirectory = workDirectory
        self.logOutput = logOutput
        
        super.init()
    }
    
//    override init() {
//
//        self.sourceFilename = ""
//        self.workDirectory = ""
//        self.arguments = ""
//        self.logOutput = true
//
//        super.init()
//    }
    
    /// Runs Zokrates
    override func main() {
            
        guard isCancelled == false else { return }
        
        // Create build directory
        if self.createBuildDirectory() == false {
            assertionFailure()
            return
        }
        
        // Set up task

        // Exporting Zokrates paths in environment. May not be necessary
        let zokratesDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".zokrates")
        let zokratesBinPath = zokratesDirectory.appendingPathComponent("bin").path
//        let zokratesHomePath = zokratesDirectory.appendingPathComponent("stdlib").path
//        self.task.environment = ProcessInfo().environment
//        self.task.environment?.updateValue("/usr/local/bin/:/usr/bin:/bin:/usr/sbin:/sbin:\(zokratesBinPath)", forKey: "PATH")
//        self.task.environment?.updateValue(zokratesHomePath, forKey: "ZOKRATES_HOME")
        
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

/// Compiles code, returns warnings and errors
/// ./zokrates compile -i playground/root.code
class Lint: ShellOperation {
    
    override func main() {
        
        self.task.arguments = ["compile", "-i", "../" + self.sourceFilename]
        super.main()
        
//        let command = "cd " + self.buildDirectory + "; " + self.zokratesBinPath + "/zokrates compile -i ../" + self.filename
//        self.write(command)
//        self.task.waitUntilExit()
    }
}

/// Compiles and builds product and proofs
/*class Compile: ShellOperation {
    
    let arguments: [String]?
    
    init(workDirectory: String, filename: String, arguments: [String]?) {
        
        self.arguments = arguments
        
        super.init(workDirectory: workDirectory, sourceFilename: filename)
    }
    
    override func main() {
        
        super.main()
        
        // 1. Create build directory
        if self.createBuildDirectory() == false {
            assertionFailure()
            return
        }
        
        // 1. Set time format
        self.write("TIMEFORMAT='Elapsed time: %3R'")
        
        // 2. Compile
        self.write("time ./zokrates compile -i " + self.dockerFilename)
        copy(file: "out")
        copy(file: "out.code")
        
        // 3. Setup
        self.write("time ./zokrates setup")
        copy(file: "proving.key")
        copy(file: "variables.inf")
        copy(file: "verification.key")
        
        // 4. Compute witness
        var command = "time ./zokrates compute-witness"
        if let arguments = self.arguments {
            command += " -a "
            _ = arguments.map{ command.append($0 + " ") }
        }
        self.write(command)
        copy(file: "witness")

        // 5. Generate proof
        self.write("time ./zokrates generate-proof")
        copy(file: "proof.json")
        
        // copy verifier
        self.write("time ./zokrates export-verifier")
        copy(file: "verifier.sol")
        
        self.write("exit")
        self.task.waitUntilExit()
    }
}
*/
